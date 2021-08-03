import UIKit
import BlocksModels

extension BlockText.Style {
    var uiFont: UIFont {
        switch self {
        case .title:
            return .title
        case .header:
            return .heading
        case .header2:
            return .subheading
        case .header3:
            return .headlineSemibold
        case .quote:
            return .headline
        case .text, .checkbox, .bulleted, .numbered, .toggle, .header4, .description:
            return .body
        case .code:
            return .code
        }
    }
}
