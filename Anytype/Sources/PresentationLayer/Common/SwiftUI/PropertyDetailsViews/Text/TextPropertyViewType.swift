import Foundation
import UIKit

enum TextPropertyViewType {
    case text
    case number
    case numberOfDays
    case phone
    case email
    case url
}

extension TextPropertyViewType {
    
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
        case .text: return Loc.enterText
        case .number: return Loc.enterNumber
        case .numberOfDays: return Loc.EditSet.Popup.Filters.TextView.placeholder
        case .phone: return Loc.enterPhoneNumber
        case .email: return Loc.enterEmail
        case .url: return Loc.enterURL
        }
    }
    
}
