import BlocksModels
import Combine

final class SetViewSettingsGroupByViewModel: CheckPopupViewViewModelProtocol {
    let title: String = Loc.Set.View.Settings.GroupBy.title
    @Published private(set) var items: [CheckPopupItem] = []

    private var selectedRelationId: String
    private var relations: [RelationMetadata]
    private let onSelect: (String) -> Void

    // MARK: - Initializer

    init(
        selectedRelationId: String,
        relations: [RelationMetadata],
        onSelect: @escaping (String) -> Void
    ) {
        self.selectedRelationId = selectedRelationId
        self.relations = relations
        self.onSelect = onSelect
        self.items = self.buildPopupItems()
    }
    
    func buildPopupItems() -> [CheckPopupItem] {
        relations.compactMap { relation in
            CheckPopupItem(
                id: relation.key,
                iconAsset: relation.format.iconAsset,
                title: relation.name,
                subtitle: nil,
                isSelected: relation.id == selectedRelationId,
                onTap: { [weak self] in self?.onTap(relation: relation) }
            )
        }
    }

    private func onTap(relation: RelationMetadata) {
        guard relation.id != selectedRelationId else {
            return
        }

        selectedRelationId = relation.id
        onSelect(relation.id)
        items = buildPopupItems()
    }
}
