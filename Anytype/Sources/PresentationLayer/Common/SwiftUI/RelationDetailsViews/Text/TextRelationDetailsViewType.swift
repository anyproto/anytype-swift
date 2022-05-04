import Foundation
import UIKit

enum TextRelationDetailsViewType {
    
    case text
    case number
    case phone
    case email
    case url
    
}

extension TextRelationDetailsViewType {
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .text: return .default
        case .number: return .decimalPad
        case .phone: return .phonePad
        case .email: return .emailAddress
        case .url: return .URL
        }
    }
    
    var placeholder: String {
        switch self {
        case .text: return "Add text".localized
        case .number: return "Add number".localized
        case .phone: return "Add phone number".localized
        case .email: return "Add email".localized
        case .url: return "Add URL".localized
        }
    }
    
}
