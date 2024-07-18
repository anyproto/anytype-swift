import Foundation

extension LegacySearchViewModel {
    enum CreateButtonModel {
        case disabled
        case enabled(title: String)
    }
}


extension LegacySearchViewModel.CreateButtonModel {
    
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
