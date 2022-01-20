import Foundation
import UIKit

enum TextRelationEditingViewType {
    
    case text
    case number
    
}

extension TextRelationEditingViewType {
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .text: return .default
        case .number: return .decimalPad
        }
    }
    
    var placeholder: String {
        switch self {
        case .text: return "Add text".localized
        case .number: return "Add number".localized
        }
    }
    
}
