import BlocksModels
import Combine

final class SetViewSettingsGroupByViewModel: CheckPopupViewViewModelProtocol {
    let title: String = Loc.Set.View.Settings.GroupBy.title
    @Published private(set) var items: [CheckPopupItem] = []

    private var selectedRelationKey: String
    private var relations: [RelationDetails]
    private let onSelect: (String) -> Void

    // MARK: - Initializer

    init(
        selectedRelationKey: String,
        relations: [RelationDetails],
        onSelect: @escaping (String) -> Void
    ) {
        self.selectedRelationKey = selectedRelationKey
        self.relations = relations
        self.onSelect = onSelect
        self.items = self.buildPopupItems()
    }
    
    func buildPopupItems() -> [CheckPopupItem] {
        relations.compactMap { relation in
            CheckPopupItem(
                id: relation.id,
                iconAsset: relation.format.iconAsset,
                title: relation.name,
                subtitle: nil,
                isSelected: relation.key == selectedRelationKey,
                onTap: { [weak self] in self?.onTap(relation: relation) }
            )
        }
    }

    private func onTap(relation: RelationDetails) {
        guard relation.key != selectedRelationKey else {
            return
        }

        selectedRelationKey = relation.key
        onSelect(relation.key)
        items = buildPopupItems()
    }
}
