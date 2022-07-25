import SwiftUI
import BlocksModels

final class SetFiltersCheckboxViewModel: ObservableObject {
    @Published var isChecked = true
    
    let onApplyCheckbox: (Bool) -> Void
    
    init(filter: SetFilter, onApplyCheckbox: @escaping (Bool) -> Void) {
        self.isChecked = filter.filter.value.boolValue
        self.onApplyCheckbox = onApplyCheckbox
    }
    
    func changeState() {
        isChecked = !isChecked
    }

    func handleCheckbox() {
        onApplyCheckbox(isChecked)
    }
    
    func stateIsChecked(_ state: SetFiltersCheckboxState) -> Bool {
        (state == .checked && isChecked) || (state == .unchecked && !isChecked)
    }
}
