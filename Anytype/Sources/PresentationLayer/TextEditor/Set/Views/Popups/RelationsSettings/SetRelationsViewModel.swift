import FloatingPanel
import SwiftUI
import ProtobufMessages
import Services
import AnytypeCore
import Combine

@MainActor
final class SetRelationsViewModel: ObservableObject {
    @Published var contentViewType: SetContentViewType = .table
    
    private let setDocument: SetDocumentProtocol
    private let viewId: String
    private let dataviewService: DataviewServiceProtocol
    // TODO: Remove router with FeatureFlags.newSetSettings
    private let router: EditorSetRouterProtocol?
    
    private weak var output: SetRelationsCoordinatorOutput?
    
    private var cancellable: Cancellable?
    
    private var view: DataviewView = .empty
    
    var cardSizeSetting: SetViewSettingsValueItem {
        SetViewSettingsValueItem(
            title: Loc.Set.View.Settings.CardSize.title,
            value: view.cardSize.value,
            onTap: { [weak self] in
                self?.showCardSizes()
            }
        )
    }
    
    var iconSetting: SetViewSettingsToggleItem {
        SetViewSettingsToggleItem(
            title: Loc.icon,
            isSelected: !view.hideIcon,
            onChange: { [weak self] show in
                self?.onShowIconChange(show)
            }
        )
    }
    
    var imagePreviewSetting: SetViewSettingsValueItem {
        SetViewSettingsValueItem(
            title: Loc.Set.View.Settings.ImagePreview.title,
            value: imagePreviewValue(),
            onTap: { [weak self] in
                self?.showCovers()
            }
        )
    }
    
    var coverFitSetting: SetViewSettingsToggleItem {
        SetViewSettingsToggleItem(
            title: Loc.Set.View.Settings.ImageFit.title,
            isSelected: view.coverFit,
            onChange: { [weak self] fit in
                self?.onCoverFitChange(fit)
            }
        )
    }
    
    var groupBySetting: SetViewSettingsValueItem {
        SetViewSettingsValueItem(
            title: Loc.Set.View.Settings.GroupBy.title,
            value: groupByValue(with: view.groupRelationKey),
            onTap: { [weak self] in
                self?.showGroupByRelations()
            }
        )
    }
    
    var groupBackgroundColorsSetting: SetViewSettingsToggleItem {
        SetViewSettingsToggleItem(
            title: Loc.Set.View.Settings.GroupBackgroundColors.title,
            isSelected: view.groupBackgroundColors,
            onChange: { [weak self] colored in
                self?.onGroupBackgroundColorsChange(colored)
            }
        )
    }
    
    var relations: [SetViewSettingsRelation] {
        setDocument.sortedRelations(for: viewId).map { relation in
            SetViewSettingsRelation(
                id: relation.id,
                image: relation.relationDetails.format.iconAsset,
                title: relation.relationDetails.name,
                isOn: relation.option.isVisible,
                canBeRemovedFromObject: relation.relationDetails.canBeRemovedFromObject,
                onChange: { [weak self] isVisible in
                    self?.onRelationVisibleChange(relation, isVisible: isVisible)
                }
            )
        }
    }
    
    init(
        setDocument: SetDocumentProtocol,
        viewId: String,
        dataviewService: DataviewServiceProtocol,
        output: SetRelationsCoordinatorOutput?,
        router: EditorSetRouterProtocol?
    ) {
        self.setDocument = setDocument
        self.viewId = viewId
        self.dataviewService = dataviewService
        self.output = output
        self.router = router
        self.setup()
    }
    
    func deleteRelations(indexes: IndexSet) {
        indexes.forEach { index in
            guard let relation = setDocument.sortedRelations(for: viewId)[safe: index] else {
                anytypeAssertionFailure("No relation to delete", info: ["index": "\(index)"])
                return
            }
            Task {
                let key = relation.relationDetails.key
                try await dataviewService.deleteRelation(
                    objectId: setDocument.objectId,
                    blockId: setDocument.blockId,
                    relationKey: key
                )
                try await dataviewService.removeViewRelations(
                    objectId: setDocument.objectId,
                    blockId: setDocument.blockId,
                    keys: [key],
                    viewId: viewId
                )
            }
        }
    }
    
    func moveRelation(from: IndexSet, to: Int) {
        from.forEach { [weak self] sortedRelationsFromIndex in
            guard let self, sortedRelationsFromIndex != to else { return }
            
            let sortedRelations = setDocument.sortedRelations(for: viewId)
            let relationFrom = sortedRelations[sortedRelationsFromIndex]
            let sortedRelationsToIndex = to > sortedRelationsFromIndex ? to - 1 : to // map insert index to item index
            let relationTo = sortedRelations[sortedRelationsToIndex]
            let options = view.options
            
            // index in all options array (includes hidden options)
            guard let indexFrom = options.index(of: relationFrom) else {
                anytypeAssertionFailure("No from relation for move", info: ["key": relationFrom.relationDetails.key])
                return
            }
            guard let indexTo = options.index(of: relationTo) else {
                anytypeAssertionFailure("No to relation for move", info: ["key": relationTo.relationDetails.key])
                return
            }
            
            var newOptions = options
            newOptions.moveElement(from: indexFrom, to: indexTo)
            let keys = newOptions.map { $0.key }
            Task { [weak self] in
                guard let self else { return }
                try await dataviewService.sortViewRelations(
                    objectId: setDocument.objectId,
                    blockId: setDocument.blockId,
                    keys: keys,
                    viewId: viewId
                )
            }
        }
    }
    
    func showAddNewRelationView() {
        output?.onAddButtonTap { relation, isNew in
            AnytypeAnalytics.instance().logAddRelation(format: relation.format, isNew: isNew, type: .dataview)
        }
    }
    
    private func setup() {
        cancellable = setDocument.syncPublisher.sink {  [weak self] in
            guard let self else { return }
            view = setDocument.view(by: viewId)
            contentViewType = view.type.setContentViewType
        }
    }
    
    private func onRelationVisibleChange(_ relation: SetRelation, isVisible: Bool) {
        Task {
            let newOption = relation.option.updated(isVisible: isVisible).asMiddleware
            try await dataviewService.replaceViewRelation(
                objectId: setDocument.objectId,
                blockId: setDocument.blockId,
                key: relation.option.key,
                with: newOption,
                viewId: viewId
            )
        }
    }
    
    private func onShowIconChange(_ show: Bool) {
        let newView = view.updated(hideIcon: !show)
        updateView(newView)
    }
    
    private func onImagePreviewChange(_ key: String) {
        let newView = view.updated(coverRelationKey: key)
        updateView(newView)
    }
    
    private func onCoverFitChange(_ fit: Bool) {
        let newView = view.updated(coverFit: fit)
        updateView(newView)
    }
    
    private func onGroupBackgroundColorsChange(_ colored: Bool) {
        let newView = view.updated(groupBackgroundColors: colored)
        updateView(newView)
    }
    
    private func onGroupBySettingChange(_ key: String) {
        let newView = view.updated(groupRelationKey: key)
        updateView(newView)
    }
    
    private func onCardSizeChange(_ size: DataviewViewSize) {
        let newView = view.updated(cardSize: size)
        updateView(newView)
    }
    
    private func updateView(_ view: DataviewView) {
        Task {
            try await dataviewService.updateView(
                objectId: setDocument.objectId,
                blockId: setDocument.blockId,
                view: view
            )
        }
    }
    
    private func imagePreviewValue() -> String {
        imagePreviewValueFromCovers() ?? imagePreviewValueFromRelations() ?? ""
    }
    
    private func imagePreviewValueFromCovers() -> String? {
        SetViewSettingsImagePreviewCover.allCases.first { cover in
            return cover.rawValue == view.coverRelationKey
        }?.title
    }
    
    private func imagePreviewValueFromRelations() -> String? {
        setDocument.dataViewRelationsDetails.first { relationDetails in
            return relationDetails.key == view.coverRelationKey
        }?.name
    }
    
    private func mappedCardSize() -> DataviewViewSize {
        if view.cardSize == .medium {
            return .large
        }
        return view.cardSize
    }
    
    private func groupByValue(with key: String) -> String {
        setDocument.dataViewRelationsDetails.first { relation in
            relation.key == key
        }?.name ?? key
    }
    
    private func showCardSizes() {
        router?.showCardSizes(
            size: mappedCardSize(),
            onSelect: { [weak self] size in
                self?.onCardSizeChange(size)
            }
        )
    }
    
    private func showCovers() {
        router?.showCovers(
            setDocument: setDocument,
            onSelect: { [weak self] key in
                self?.onImagePreviewChange(key)
            }
        )
    }
    
    private func showGroupByRelations() {
        router?.showGroupByRelations { [weak self] key in
            self?.onGroupBySettingChange(key)
        }
    }
}
