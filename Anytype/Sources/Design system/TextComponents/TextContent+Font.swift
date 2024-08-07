import UIKit
import Services

extension BlockText.Style {
    var uiFont: AnytypeFont {
        switch self {
        case .title:
            return .title
        case .description:
            return .relation1Regular
        case .header:
            return .title
        case .header2:
            return .heading
        case .header3:
            return .subheading
        case .text, .checkbox, .bulleted, .numbered, .toggle, .header4, .quote, .callout:
            return .bodyRegular
        case .code:
            return .codeBlock
        }
    }
}
