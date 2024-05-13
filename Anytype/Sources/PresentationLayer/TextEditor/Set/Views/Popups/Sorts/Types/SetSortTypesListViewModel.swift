import Services
import Combine
import AnytypeCore

@MainActor
final class SetSortTypesListViewModel: ObservableObject {
    
    let title: String
    @Published private(set) var typeItems: [SetSortTypeItem] = []
    @Published private(set) var emptyTypeItems: [SetSortTypeItem] = []

    private let sort: SetSort
    private var selectedSort: DataviewSort
    private let completion: (SetSort, String) -> Void

    // MARK: - Initializer

    init(data: SetSortTypesData) {
        self.title = data.setSort.relationDetails.name
        self.sort = data.setSort
        self.selectedSort = data.setSort.sort
        self.completion = data.completion
        self.typeItems = buildTypeItems()
        if FeatureFlags.setEmptyValuesSorting {
            self.emptyTypeItems = buildEmptyTypeItems()
        }
    }
    
    func buildTypeItems() -> [SetSortTypeItem] {
        DataviewSort.TypeEnum.allAvailableCases.compactMap { type in
            guard let title = sort.typeTitle(for: type) else { return nil }
            return SetSortTypeItem(
                title: title,
                isSelected: type == selectedSort.type,
                onTap: { [weak self] in self?.onTypeTap(item: type) }
            )
        }
    }
    
    func buildEmptyTypeItems() -> [SetSortTypeItem] {
        DataviewSort.EmptyType.allAvailableCases.compactMap { type in
            guard let title = sort.emptyTypeTitle(for: type) else { return nil }
            return SetSortTypeItem(
                title: title,
                isSelected: type == selectedSort.emptyPlacement,
                onTap: { [weak self] in self?.onEmptyTap(item: type) }
            )
        }
    }

    private func onTypeTap(item: DataviewSort.TypeEnum) {
        guard item != selectedSort.type else {
            return
        }

        selectedSort.type = item
        completion(
            SetSort(
                relationDetails: sort.relationDetails,
                sort: selectedSort
            ),
            item.analyticValue
        )
        typeItems = buildTypeItems()
    }
    
    private func onEmptyTap(item: DataviewSort.EmptyType) {
        guard item != selectedSort.emptyPlacement else {
            return
        }

        selectedSort.emptyPlacement = item
        completion(
            SetSort(
                relationDetails: sort.relationDetails,
                sort: selectedSort
            ),
            item.analyticValue
        )
        emptyTypeItems = buildEmptyTypeItems()
    }
}
