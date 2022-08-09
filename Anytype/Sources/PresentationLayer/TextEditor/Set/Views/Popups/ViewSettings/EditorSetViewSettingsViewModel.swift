import FloatingPanel
import SwiftUI
import ProtobufMessages
import BlocksModels
import AnytypeCore

final class EditorSetViewSettingsViewModel: ObservableObject {
    private let setModel: EditorSetViewModel
    private let service: DataviewServiceProtocol
    private let router: EditorRouterProtocol

    var cardSizeSetting: EditorSetViewSettingsValueItem {
        EditorSetViewSettingsValueItem(
            title: Loc.Set.View.Settings.CardSize.title,
            value: setModel.activeView.cardSize.value,
            onTap: { [weak self] in
                self?.showCardSizes()
            }
        )
    }
    
    var iconSetting: EditorSetViewSettingsToggleItem {
        EditorSetViewSettingsToggleItem(
            title: Loc.icon,
            isSelected: !setModel.activeView.hideIcon,
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
            isSelected: setModel.activeView.coverFit,
            onChange: { [weak self] fit in
                self?.onCoverFitChange(fit)
            }
        )
    }
    
    var relations: [EditorSetViewSettingsRelation] {
        setModel.sortedRelations.map { relation in
            EditorSetViewSettingsRelation(
                id: relation.id,
                image: relation.metadata.format.iconAsset,
                title: relation.metadata.name,
                isOn: relation.option.isVisible,
                isBundled: relation.metadata.isBundled,
                onChange: { [weak self] isVisible in
                    self?.onRelationVisibleChange(relation, isVisible: isVisible)
                }
            )
        }
    }
    
    var needShowAllSettings: Bool {
        setModel.activeView.type == .gallery
    }
    
    init(setModel: EditorSetViewModel, service: DataviewServiceProtocol, router: EditorRouterProtocol) {
        self.setModel = setModel
        self.service = service
        self.router = router
    }
    
    func deleteRelations(indexes: IndexSet) {
        indexes.forEach { index in
            guard let relation = setModel.sortedRelations[safe: index] else {
                anytypeAssertionFailure("No relation to delete at index: \(index)", domain: .dataviewService)
                return
            }
            service.deleteRelation(key: relation.metadata.key)
        }
    }
    
    func moveRelation(from: IndexSet, to: Int) {
        from.forEach { sortedRelationsFromIndex in
            guard sortedRelationsFromIndex != to else { return }
            
            let relationFrom = setModel.sortedRelations[sortedRelationsFromIndex]
            let sortedRelationsToIndex = to > sortedRelationsFromIndex ? to - 1 : to // map insert index to item index
            let relationTo = setModel.sortedRelations[sortedRelationsToIndex]
            
            // index in all options array (includes hidden options)
            guard let indexFrom = setModel.activeView.options.index(of: relationFrom) else {
                anytypeAssertionFailure("No relation for move: \(relationFrom)", domain: .dataviewService)
                return
            }
            guard let indexTo = setModel.activeView.options.index(of: relationTo) else {
                anytypeAssertionFailure("No relation for move: \(relationTo)", domain: .dataviewService)
                return
            }
            
            var newOptions = setModel.activeView.options
            newOptions.moveElement(from: indexFrom, to: indexTo)
            let newView = setModel.activeView.updated(options: newOptions)
            service.updateView(newView)
        }
    }
    
    func showAddNewRelationView() {
        setModel.showAddNewRelationView { [weak self] relation, isNew in
            guard let self = self else { return }
            
            if self.service.addRelation(relation) {
                let newOption = DataviewRelationOption(key: relation.key, isVisible: true)
                let newView = self.setModel.activeView.updated(option: newOption)
                self.service.updateView(newView)
            }
            AnytypeAnalytics.instance().logAddRelation(format: relation.format, isNew: isNew, type: .set)
        }
    }
    
    private func onRelationVisibleChange(_ relation: SetRelation, isVisible: Bool) {
        let newOption = relation.option.updated(isVisible: isVisible)
        let newView = setModel.activeView.updated(option: newOption)
        service.updateView(newView)
    }
    
    private func onShowIconChange(_ show: Bool) {
        let newView = setModel.activeView.updated(hideIcon: !show)
        service.updateView(newView)
    }
    
    private func onImagePreviewChange(_ key: String) {
        let newView = setModel.activeView.updated(coverRelationKey: key)
        service.updateView(newView)
    }
    
    private func onCoverFitChange(_ fit: Bool) {
        let newView = setModel.activeView.updated(coverFit: fit)
        service.updateView(newView)
    }
    
    private func onCardSizeChange(_ size: DataviewViewSize) {
        let newView = setModel.activeView.updated(cardSize: size)
        service.updateView(newView)
    }
    
    private func imagePreviewValue() -> String {
        imagePreviewValueFromCovers() ?? imagePreviewValueFromRelations() ?? ""
    }
    
    private func imagePreviewValueFromCovers() -> String? {
        SetViewSettingsImagePreviewCover.allCases.first { [weak self] cover in
            guard let self = self else { return false }
            return cover.rawValue == self.setModel.activeView.coverRelationKey
        }?.title
    }
    
    private func imagePreviewValueFromRelations() -> String? {
        setModel.dataView.relations.first { [weak self] relation in
            guard let self = self else { return false }
            return relation.key == self.setModel.activeView.coverRelationKey
        }?.name
    }
    
    private func showCardSizes() {
        router.showCardSizes(
            size: setModel.activeView.cardSize,
            onSelect: { [weak self] size in
                self?.onCardSizeChange(size)
            }
        )
    }
    
    private func showCovers() {
        router.showCovers(
            setModel: setModel,
            onSelect: { [weak self] key in
                self?.onImagePreviewChange(key)
            }
        )
    }
}
