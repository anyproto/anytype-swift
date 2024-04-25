import Services
import Combine

@MainActor
final class SetFilterConditionsViewModel: CheckPopupViewViewModelProtocol {
    @Published private(set) var items: [CheckPopupItem] = []
    let title: String

    private let filter: SetFilter
    private var selectedCondition: DataviewFilter.Condition
    private let onSelect: (DataviewFilter.Condition) -> Void

    // MARK: - Initializer

    init(data: SetFilterConditions) {
        self.title = data.filter.relationDetails.name
        self.filter = data.filter
        self.selectedCondition = data.filter.filter.condition
        self.onSelect = data.completion
        self.items = self.buildPopupItems()
    }
    
    private func buildPopupItems() -> [CheckPopupItem] {
        filter.conditionType.data.compactMap { condition, title in
            CheckPopupItem(
                id: String(condition.rawValue),
                iconAsset: nil,
                title: title,
                subtitle: nil,
                isSelected: selectedCondition == condition,
                onTap: { [weak self] in self?.onTap(condition: condition) }
            )
        }
    }

    private func onTap(condition: DataviewFilter.Condition) {
        guard condition != selectedCondition else {
            return
        }
        selectedCondition = condition
        items = buildPopupItems()
        onSelect(condition)
    }
}
