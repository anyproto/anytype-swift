import UIKit
import BlocksModels

extension BlockText.Style {
    var uiFont: AnytypeFont {
        switch self {
        case .title:
            return .title
        case .description:
            return .caption1Regular
        case .header:
            return .title
        case .header2:
            return .heading
        case .header3:
            return .subheading
        case .text, .checkbox, .bulleted, .numbered, .toggle, .header4, .quote, .callout:
            return .body
        case .code:
            return .codeBlock
        }
    }
}
