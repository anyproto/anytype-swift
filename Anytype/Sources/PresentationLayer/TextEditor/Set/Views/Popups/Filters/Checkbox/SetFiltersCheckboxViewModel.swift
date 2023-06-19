import SwiftUI
import Services

final class SetFiltersCheckboxViewModel: ObservableObject {
    @Published var value: SetFiltersCheckboxValue = .checked
    
    let onApplyCheckbox: (Bool) -> Void
    
    init(filter: SetFilter, onApplyCheckbox: @escaping (Bool) -> Void) {
        self.value = filter.filter.value.boolValue ? .checked : .unchecked
        self.onApplyCheckbox = onApplyCheckbox
    }
    
    func changeState(with value: SetFiltersCheckboxValue) {
        guard self.value != value else {
            return
        }
        self.value = value
    }

    func handleCheckbox() {
        onApplyCheckbox(value == .checked)
    }
}
