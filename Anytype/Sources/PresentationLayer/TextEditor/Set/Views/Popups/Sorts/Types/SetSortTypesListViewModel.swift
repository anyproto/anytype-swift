import Services
import Combine

@MainActor
final class SetSortTypesListViewModel: CheckPopupViewViewModelProtocol {
    let title: String
    @Published private(set) var items: [CheckPopupItem] = []

    private let sort: SetSort
    private var selectedSort: DataviewSort
    private let completion: (SetSort) -> Void

    // MARK: - Initializer

    init(data: SortTypesData) {
        self.title = data.setSort.relationDetails.name
        self.sort = data.setSort
        self.selectedSort = data.setSort.sort
        self.completion = data.completion
        self.items = self.buildPopupItems()
    }
    
    func buildPopupItems() -> [CheckPopupItem] {
        DataviewSort.TypeEnum.allAvailableCases.compactMap { type in
            CheckPopupItem(
                id: String(type.rawValue),
                iconAsset: nil,
                title: sort.typeTitle(for: type),
                subtitle: nil,
                isSelected: type == selectedSort.type,
                onTap: { [weak self] in self?.onTap(item: type) }
            )
        }
    }

    private func onTap(item: DataviewSort.TypeEnum) {
        guard item != selectedSort.type else {
            return
        }

        let dataviewSort = DataviewSort(
            id: selectedSort.id,
            relationKey: selectedSort.relationKey,
            type: item
        )
        selectedSort = dataviewSort
        completion(
            SetSort(
                relationDetails: sort.relationDetails,
                sort: dataviewSort
            )
        )
        items = buildPopupItems()
    }
}

struct SortTypesData: Identifiable {
    var id: String { setSort.id }
    let setSort: SetSort
    let completion: (SetSort) -> Void
}
