import SwiftUI
import BlocksModels

final class SetFiltersDateViewModel: ObservableObject {
    @Published var quickOption: DataviewFilter.QuickOption
    @Published var date: Date
    @Published var numberOfDays: Int
    
    private let filter: SetFilter
    
    var rows: [SetFiltersDateRowConfiguration] {
        DataviewFilter.QuickOption.orderedCases.map { option in
            SetFiltersDateRowConfiguration(
                id: option.rawValue,
                title: option.title,
                isSelected: option == quickOption,
                dateType: dateType(for: option),
                onTap: { [weak self] in
                    self?.handleOptionTap(option)
                }
            )
        }
    }
    
    let onApplyDate: (SetFiltersDate) -> Void
    
    init(
        filter: SetFilter,
        onApplyDate: @escaping (SetFiltersDate) -> Void)
    {
        self.filter = filter
        self.quickOption = filter.filter.quickOption
        if let timeInterval = filter.filter.value.safeDoubleValue, !timeInterval.isZero {
            self.date =  Date(timeIntervalSince1970: timeInterval)
        } else {
            self.date = Date()
        }
        self.numberOfDays = Int(filter.filter.value.safeDoubleValue ?? 0)
        self.onApplyDate = onApplyDate
    }
    
    func handleDate() {
        onApplyDate(
            SetFiltersDate(
                quickOption: quickOption,
                numberOfDays: numberOfDays,
                date: date
            )
        )
    }
     
    private func handleOptionTap(_ option: DataviewFilter.QuickOption) {
        quickOption = option
    }
    
    private func dateType(for option: DataviewFilter.QuickOption) -> SetFiltersDateType {
        switch option {
        case .numberOfDaysAgo, .numberOfDaysNow:
            let count = Int(filter.filter.value.safeDoubleValue ?? 0)
            return .days(count: "\(count)")
        case .exactDate:
            return .exactDate
        default:
            return .default
        }
    }
}
