import BlocksModels
import Combine

final class SetViewSettingsGroupByViewModel: CheckPopupViewViewModelProtocol {
    let title: String = Loc.Set.View.Settings.GroupBy.title
    @Published private(set) var items: [CheckPopupItem] = []

    private var selectedRelationId: String
    private var relations: [RelationDetails]
    private let onSelect: (String) -> Void

    // MARK: - Initializer

    init(
        selectedRelationId: String,
        relations: [RelationDetails],
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
                isSelected: relation.id == selectedRelationId
            )
        }
    }

    func onTap(itemId: String) {
        guard itemId != selectedRelationId else {
            return
        }

        selectedRelationId = itemId
        onSelect(selectedRelationId)
        items = buildPopupItems()
    }
}
