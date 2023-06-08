import FloatingPanel
import SwiftUI
import ProtobufMessages
import BlocksModels
import AnytypeCore
import Combine

final class EditorSetViewSettingsViewModel: ObservableObject {
    @Published var contentViewType: SetContentViewType = .table
    
    private let setDocument: SetDocumentProtocol
    private let dataviewService: DataviewServiceProtocol
    private let router: EditorSetRouterProtocol
    
    private var cancellable: Cancellable?

    var cardSizeSetting: EditorSetViewSettingsValueItem {
        EditorSetViewSettingsValueItem(
            title: Loc.Set.View.Settings.CardSize.title,
            value: setDocument.activeView.cardSize.value,
            onTap: { [weak self] in
                self?.showCardSizes()
            }
        )
    }
    
    var iconSetting: EditorSetViewSettingsToggleItem {
        EditorSetViewSettingsToggleItem(
            title: Loc.icon,
            isSelected: !setDocument.activeView.hideIcon,
            onChange: { [weak self] show in
                self?.onShowIconChange(show)
            }
        )
    }
    
    var imagePreviewSetting: EditorSetViewSettingsValueItem {
        EditorSetViewSettingsValueItem(
            title: Loc.Set.View.Settings.ImagePreview.title,
            value: imagePreviewValue(),
            onTap: { [weak self] in
                self?.showCovers()
            }
        )
    }
    
    var coverFitSetting: EditorSetViewSettingsToggleItem {
        EditorSetViewSettingsToggleItem(
            title: Loc.Set.View.Settings.ImageFit.title,
            isSelected: setDocument.activeView.coverFit,
            onChange: { [weak self] fit in
                self?.onCoverFitChange(fit)
            }
        )
    }
    
    var groupBySetting: EditorSetViewSettingsValueItem {
        EditorSetViewSettingsValueItem(
            title: Loc.Set.View.Settings.GroupBy.title,
            value: groupByValue(with: setDocument.activeView.groupRelationKey),
            onTap: { [weak self] in
                self?.showGroupByRelations()
            }
        )
    }
    
    var groupBackgroundColorsSetting: EditorSetViewSettingsToggleItem {
        EditorSetViewSettingsToggleItem(
            title: Loc.Set.View.Settings.GroupBackgroundColors.title,
            isSelected: setDocument.activeView.groupBackgroundColors,
            onChange: { [weak self] colored in
                self?.onGroupBackgroundColorsChange(colored)
            }
        )
    }
    
    var relations: [EditorSetViewSettingsRelation] {
        setDocument.sortedRelations.map { relation in
            EditorSetViewSettingsRelation(
                id: relation.id,
                image: relation.relationDetails.format.iconAsset,
                title: relation.relationDetails.name,
                isOn: relation.option.isVisible,
                isSystem: relation.relationDetails.isSystem,
                onChange: { [weak self] isVisible in
                    self?.onRelationVisibleChange(relation, isVisible: isVisible)
                }
            )
        }
    }
    
    init(setDocument: SetDocumentProtocol, dataviewService: DataviewServiceProtocol, router: EditorSetRouterProtocol) {
        self.setDocument = setDocument
        self.dataviewService = dataviewService
        self.router = router
        self.setup()
    }
    
    func deleteRelations(indexes: IndexSet) {
        indexes.forEach { index in
            guard let relation = setDocument.sortedRelations[safe: index] else {
                anytypeAssertionFailure("No relation to delete at index: \(index)", domain: .dataviewService)
                return
            }
            Task {
                let key = relation.relationDetails.key
                try await dataviewService.deleteRelation(relationKey: key)
                try await dataviewService.removeViewRelations([key], viewId: setDocument.activeView.id)
            }
        }
    }
    
    func moveRelation(from: IndexSet, to: Int) {
        from.forEach { [weak self] sortedRelationsFromIndex in
            guard let self = self, sortedRelationsFromIndex != to else { return }
            
            let relationFrom = setDocument.sortedRelations[sortedRelationsFromIndex]
            let sortedRelationsToIndex = to > sortedRelationsFromIndex ? to - 1 : to // map insert index to item index
            let relationTo = setDocument.sortedRelations[sortedRelationsToIndex]
            
            // index in all options array (includes hidden options)
            guard let indexFrom = setDocument.activeView.options.index(of: relationFrom) else {
                anytypeAssertionFailure("No relation for move: \(relationFrom)", domain: .dataviewService)
                return
            }
            guard let indexTo = setDocument.activeView.options.index(of: relationTo) else {
                anytypeAssertionFailure("No relation for move: \(relationTo)", domain: .dataviewService)
                return
            }
            
            var newOptions = setDocument.activeView.options
            newOptions.moveElement(from: indexFrom, to: indexTo)
            let keys = newOptions.map { $0.key }
            Task {
                try await self.dataviewService.sortViewRelations(keys, viewId: setDocument.activeView.id)
            }
        }
    }
    
    func showAddNewRelationView() {
        router.showAddNewRelationView { relation, isNew in
            AnytypeAnalytics.instance().logAddRelation(format: relation.format, isNew: isNew, type: .dataview)
        }
    }
    
    private func setup() {
        cancellable = setDocument.activeViewPublisher.sink { [weak self] activeView in
            self?.contentViewType = activeView.type.setContentViewType
        }
    }
    
    private func onRelationVisibleChange(_ relation: SetRelation, isVisible: Bool) {
        Task {
            let newOption = relation.option.updated(isVisible: isVisible).asMiddleware
            try await dataviewService.replaceViewRelation(
                relation.option.key,
                with: newOption,
                viewId: setDocument.activeView.id
            )
        }
    }
    
    private func onShowIconChange(_ show: Bool) {
        let newView = setDocument.activeView.updated(hideIcon: !show)
        updateView(newView)
    }
    
    private func onImagePreviewChange(_ key: String) {
        let newView = setDocument.activeView.updated(coverRelationKey: key)
        updateView(newView)
    }
    
    private func onCoverFitChange(_ fit: Bool) {
        let newView = setDocument.activeView.updated(coverFit: fit)
        updateView(newView)
    }
    
    private func onGroupBackgroundColorsChange(_ colored: Bool) {
        let newView = setDocument.activeView.updated(groupBackgroundColors: colored)
        updateView(newView)
    }
    
    private func onGroupBySettingChange(_ key: String) {
        let newView = setDocument.activeView.updated(groupRelationKey: key)
        updateView(newView)
    }
    
    private func onCardSizeChange(_ size: DataviewViewSize) {
        let newView = setDocument.activeView.updated(cardSize: size)
        updateView(newView)
    }
    
    private func updateView(_ view: DataviewView) {
        Task {
            try await dataviewService.updateView(view)
        }
    }
    
    private func imagePreviewValue() -> String {
        imagePreviewValueFromCovers() ?? imagePreviewValueFromRelations() ?? ""
    }
    
    private func imagePreviewValueFromCovers() -> String? {
        SetViewSettingsImagePreviewCover.allCases.first { [weak self] cover in
            guard let self = self else { return false }
            return cover.rawValue == self.setDocument.activeView.coverRelationKey
        }?.title
    }
    
    private func imagePreviewValueFromRelations() -> String? {
        setDocument.dataViewRelationsDetails.first { [weak self] relationDetails in
            guard let self = self else { return false }
            return relationDetails.key == self.setDocument.activeView.coverRelationKey
        }?.name
    }
    
    private func mappedCardSize() -> DataviewViewSize {
        if setDocument.activeView.cardSize == .medium {
            return .large
        }
        return setDocument.activeView.cardSize
    }
    
    private func groupByValue(with key: String) -> String {
        setDocument.dataViewRelationsDetails.first { relation in
            relation.key == key
        }?.name ?? key
    }
    
    private func showCardSizes() {
        router.showCardSizes(
            size: mappedCardSize(),
            onSelect: { [weak self] size in
                self?.onCardSizeChange(size)
            }
        )
    }
    
    private func showCovers() {
        router.showCovers(
            setDocument: setDocument,
            onSelect: { [weak self] key in
                self?.onImagePreviewChange(key)
            }
        )
    }
    
    private func showGroupByRelations() {
        router.showGroupByRelations(
            selectedRelationKey: setDocument.activeView.groupRelationKey,
            relations: groupByRelations(),
            onSelect: { [weak self] key in
                self?.onGroupBySettingChange(key)
            }
        )
    }
    
    private func groupByRelations() -> [RelationDetails] {
        setDocument.dataView.groupByRelations(
            for: setDocument.activeView,
            dataViewRelationsDetails: setDocument.dataViewRelationsDetails
        )
    }
}
