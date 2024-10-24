import Foundation

extension LegacySearchView {
    
    enum AddButtonModel {
        case disabled
        case enabled(counter: Int)
    }
    
}

extension LegacySearchView.AddButtonModel {
    
    var isDisabled: Bool {
        switch self {
        case .disabled: return true
        case .enabled: return false
        }
    }
    
    var counter: Int {
        switch self {
        case .disabled: return 0
        case .enabled(let counter): return counter
        }
    }
    
}
