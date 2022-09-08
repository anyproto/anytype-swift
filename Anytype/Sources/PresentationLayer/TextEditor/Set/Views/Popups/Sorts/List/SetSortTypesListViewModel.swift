import BlocksModels
import Combine

final class SetSortTypesListViewModel: CheckPopupViewViewModelProtocol {
    let title: String
    @Published private(set) var items: [CheckPopupItem] = []

    private let sort: SetSort
    private var selectedSort: DataviewSort
    private let onSelect: (DataviewSort) -> Void

    // MARK: - Initializer

    init(
        sort: SetSort,
        onSelect: @escaping (DataviewSort) -> Void
    ) {
        self.title = sort.relation.name
        self.sort = sort
        self.selectedSort = sort.sort
        self.onSelect = onSelect
        self.items = self.buildPopupItems()
    }
    
    func buildPopupItems() -> [CheckPopupItem] {
        DataviewSort.TypeEnum.allAvailableCases.compactMap { type in
            CheckPopupItem(
                id: String(type.rawValue),
                iconAsset: nil,
                title: sort.typeTitle(for: type),
                subtitle: nil,
                isSelected: type == selectedSort.type
            )
        }
    }

    func onTap(itemId: String) {
        guard let type =  DataviewSort.TypeEnum(rawValue: Int(itemId) ?? 0),
              type != selectedSort.type else {
            return
        }

        let sort = DataviewSort(
            relationKey: selectedSort.relationKey,
            type: type
        )
        selectedSort = sort
        onSelect(sort)
        items = buildPopupItems()
    }
}
