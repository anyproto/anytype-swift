import SwiftUI
import BlocksModels

final class SetFiltersCheckboxViewModel: ObservableObject {
    @Published var state: SetFiltersCheckboxState = .checked
    
    let onApplyCheckbox: (Bool) -> Void
    
    init(filter: SetFilter, onApplyCheckbox: @escaping (Bool) -> Void) {
        self.state = filter.filter.value.boolValue ? .checked : .unchecked
        self.onApplyCheckbox = onApplyCheckbox
    }
    
    func changeState() {
        state = state == .checked ? .unchecked : .checked
    }

    func handleCheckbox() {
        onApplyCheckbox(state == .checked)
    }
}
