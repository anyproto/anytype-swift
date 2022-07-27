import SwiftUI
import BlocksModels

final class SetFiltersDateViewModel: ObservableObject {
    @Published var quickOption: DataviewFilter.QuickOption = .today
    
    private let filter: SetFilter
    
    var rows: [SetFiltersDateRowConfiguration] {
        DataviewFilter.QuickOption.allCases.map { option in
            SetFiltersDateRowConfiguration(
                id: option.rawValue,
                title: option.title,
                isChecked: option == quickOption,
                onTap: { [weak self] in
                    self?.quickOption = option
                }
            )
        }
    }
    
    let onApplyOption: (DataviewFilter.QuickOption) -> Void
    
    init(filter: SetFilter, onApplyOption: @escaping (DataviewFilter.QuickOption) -> Void) {
        self.filter = filter
        self.quickOption = filter.filter.quickOption
        self.onApplyOption = onApplyOption
    }
    
    func handleDate(){
        onApplyOption(quickOption)
    }
}
