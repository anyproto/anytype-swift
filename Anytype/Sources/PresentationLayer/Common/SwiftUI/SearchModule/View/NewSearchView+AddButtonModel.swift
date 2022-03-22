import Foundation

extension NewSearchView {
    
    enum AddButtonModel {
        case disabled
        case enabled(counter: Int)
    }
    
}

extension NewSearchView.AddButtonModel {
    
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
