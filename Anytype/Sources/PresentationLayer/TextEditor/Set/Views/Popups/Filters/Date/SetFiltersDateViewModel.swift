import SwiftUI
import Services
import Combine

@MainActor
final class SetFiltersDateViewModel: ObservableObject {
    @Published var quickOption: DataviewFilter.QuickOption
    @Published var date: Date
    @Published var numberOfDays: Int
    @Published var condition: DataviewFilter.Condition
    
    @Published var showFiltersDaysView = false
    
    private let filter: SetFilter
    private weak var setSelectionModel: SetFiltersSelectionViewModel?
    private let onApplyDate: (SetFiltersDate) -> Void
    private var cancellable: AnyCancellable?
    
    private let setTextViewModuleAssembly = SetTextViewModuleAssembly()
    
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
        filter: SetFilter,
        setSelectionModel: SetFiltersSelectionViewModel?,
        onApplyDate: @escaping (SetFiltersDate) -> Void)
    {
        self.filter = filter
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
        
        self.onApplyDate = onApplyDate
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
    
    func filtersDaysView() -> AnyView {
        setTextViewModuleAssembly.make(
            title: quickOption.title,
            text: "\(numberOfDays)",
            onTextChanged: { [weak self] value in
                self?.numberOfDays = Int(Double(value) ?? 0)
            }
        )
    }
    
    private func setup() {
        cancellable = setSelectionModel?.$condition.sink {  [weak self] condition in
            self?.condition = condition
        }
    }
     
    private func handleOptionTap(_ option: DataviewFilter.QuickOption) {
        quickOption = option
        
        switch option {
        case .numberOfDaysAgo, .numberOfDaysNow:
            showFiltersDaysView.toggle()
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
