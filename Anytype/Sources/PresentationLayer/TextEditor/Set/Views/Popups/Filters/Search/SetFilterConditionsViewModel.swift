import BlocksModels
import Combine

final class SetFilterConditionsViewModel: CheckPopupViewViewModelProtocol {
    let title: String
    @Published private(set) var items: [CheckPopupItem] = []

    private let filter: SetFilter
    private var selectedCondition: DataviewFilter.Condition
    private let onSelect: (DataviewFilter.Condition) -> Void

    // MARK: - Initializer

    init(
        filter: SetFilter,
        onSelect: @escaping (DataviewFilter.Condition) -> Void
    ) {
        self.title = filter.metadata.name
        self.filter = filter
        self.selectedCondition = filter.filter.condition
        self.onSelect = onSelect
        self.items = self.buildPopupItems()
    }
    
    private func buildPopupItems() -> [CheckPopupItem] {
        filter.conditionType.data.compactMap { condition, title in
            CheckPopupItem(
                id: String(condition.rawValue),
                icon: nil,
                title: title,
                subtitle: nil,
                isSelected: selectedCondition == condition
            )
        }
    }

    func onTap(itemId: String) {
        guard let condition =  DataviewFilter.Condition(rawValue: Int(itemId) ?? 0),
              condition != selectedCondition else {
            return
        }
        selectedCondition = condition
        items = buildPopupItems()
        onSelect(condition)
    }
}
