import SwiftUI
import Services

@MainActor
@Observable
final class SetFiltersDateViewModel {
    var quickOption: DataviewFilter.QuickOption
    var date: Date
    var numberOfDays: Int
    var condition: DataviewFilter.Condition

    var filtersDaysData: SetTextViewData?

    @ObservationIgnored
    private let filter: SetFilter
    @ObservationIgnored
    private weak var setSelectionModel: SetFiltersSelectionViewModel?
    @ObservationIgnored
    private let onApplyDate: (SetFiltersDate) -> Void
    
    var rows: [SetFiltersDateRowConfiguration] {
        DataviewFilter.QuickOption.orderedCases(for: condition).map { option in
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
    
    init(
        data: SetFiltersDateViewData,
        setSelectionModel: SetFiltersSelectionViewModel?
    ){
        self.filter = data.filter
        self.quickOption = filter.filter.quickOption
        self.setSelectionModel = setSelectionModel
        self.condition = setSelectionModel?.condition ?? DataviewFilter.Condition.equal
        
        if filter.filter.quickOption == .exactDate,
           let timeInterval = filter.filter.value.safeDoubleValue,
            !timeInterval.isZero {
            self.date =  Date(timeIntervalSince1970: timeInterval)
        } else {
            self.date = Date()
        }
        
        if filter.filter.quickOption == .exactDate {
            self.numberOfDays = 0
        } else {
            self.numberOfDays = filter.filter.value.safeIntValue ?? 0
        }
        
        self.onApplyDate = data.onApplyDate
        self.setup()
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
    
    private func setup() {
        setSelectionModel?.onConditionChanged = { [weak self] condition in
            self?.condition = condition
        }
    }
     
    private func handleOptionTap(_ option: DataviewFilter.QuickOption) {
        quickOption = option
        
        switch option {
        case .numberOfDaysAgo, .numberOfDaysNow:
            filtersDaysData = SetTextViewData(
                title: quickOption.title,
                text: "\(numberOfDays)",
                onTextChanged: { [weak self] value in
                    self?.numberOfDays = Int(Double(value) ?? 0)
                }
            )
        default:
            break
        }
    }
    
    private func dateType(for option: DataviewFilter.QuickOption) -> SetFiltersDateType {
        switch option {
        case .numberOfDaysAgo, .numberOfDaysNow:
            return .days(count: "\(numberOfDays)")
        case .exactDate:
            return .exactDate
        default:
            return .default
        }
    }
}
