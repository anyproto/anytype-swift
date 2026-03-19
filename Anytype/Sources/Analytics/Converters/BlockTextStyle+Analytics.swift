import Foundation
import Services

extension BlockText.Style {
    var analyticsValue: String {
        switch self {
        case .title:
            return "Title"
        case .description:
            return "Description"
        case .text:
            return "Paragraph"
        case .header:
            return "Header1"
        case .header2:
            return "Header2"
        case .header3:
            return "Header3"
        case .header4:
            return "Header4"
        case .quote:
            return "Quote"
        case .checkbox:
            return "Checkbox"
        case .bulleted:
            return "Bulleted"
        case .numbered:
            return "Numbered"
        case .toggle:
            return "Toggle"
        case .code:
            return "Code"
        case .callout:
            return "Callout"
        }
    }
}
