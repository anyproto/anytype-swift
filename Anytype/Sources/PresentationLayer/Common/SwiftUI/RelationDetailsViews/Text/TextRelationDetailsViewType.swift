import Foundation
import UIKit

enum TextRelationDetailsViewType {
    
    case text
    case number
    case numberOfDays
    case phone
    case email
    case url
    
}

extension TextRelationDetailsViewType {
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .text: return .default
        case .number, .numberOfDays: return .decimalPad
        case .phone: return .phonePad
        case .email: return .emailAddress
        case .url: return .URL
        }
    }
    
    var placeholder: String {
        switch self {
        case .text: return Loc.addText
        case .number: return Loc.addNumber
        case .numberOfDays: return Loc.EditSet.Popup.Filters.TextView.placeholder
        case .phone: return Loc.addPhoneNumber
        case .email: return Loc.addEmail
        case .url: return Loc.addURL
        }
    }
    
}
