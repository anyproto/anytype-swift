import Foundation
import BlocksModels
import Combine

final class SetFiltersDateViewModel: ObservableObject {
    @Published var quickOption: DataviewFilter.QuickOption
    @Published var date: Date
    @Published var numberOfDays: Int
    @Published var condition: DataviewFilter.Condition
    
    private let filter: SetFilter
    private let router: EditorRouterProtocol
    private let setSelectionModel: SetFiltersSelectionViewModel
    private let onApplyDate: (SetFiltersDate) -> Void
    private var cancellable: AnyCancellable?
    
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
        router: EditorRouterProtocol,
        setSelectionModel: SetFiltersSelectionViewModel,
        onApplyDate: @escaping (SetFiltersDate) -> Void)
    {
        self.filter = filter
        self.router = router
        self.quickOption = filter.filter.quickOption
        self.setSelectionModel = setSelectionModel
        self.condition = setSelectionModel.condition
        
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
    
    private func setup() {
        cancellable = setSelectionModel.$condition.sink {  [weak self] condition in
            self?.condition = condition
        }
    }
     
    private func handleOptionTap(_ option: DataviewFilter.QuickOption) {
        quickOption = option
        
        switch option {
        case .numberOfDaysAgo, .numberOfDaysNow:
            showFiltersDaysView()
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
    
    private func showFiltersDaysView() {
        router.presentFullscreen(
            AnytypePopup(
                viewModel: SetFiltersDaysViewModel(
                    title: quickOption.title,
                    value: "\(numberOfDays)",
                    onValueChanged: { [weak self] value in
                        self?.numberOfDays = Int(Double(value) ?? 0)
                    }
                )
            )
        )
    }
}
