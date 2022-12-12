import Foundation

extension NewSearchViewModel {
    enum CreateButtonModel {
        case disabled
        case enabled(title: String)
    }
}


extension NewSearchViewModel.CreateButtonModel {
    
    var isDisabled: Bool {
        switch self {
        case .disabled: return true
        case .enabled: return false
        }
    }
    
    var title: String {
        switch self {
        case .disabled: return ""
        case let .enabled(title): return title
        }
    }
    
}
