import UIKit
import Services

enum TextBlockLayout {
    static func contentInset(textBlockStyle: BlockText.Style) -> NSDirectionalEdgeInsets {
        switch textBlockStyle {
        case .title:
            return .zero
        case .description:
            return .zero
        case .header:
            return .init(top: 5, leading: 0, bottom: 5, trailing: 0)
        case .header2:
            return .init(top: 5, leading: 0, bottom: 5, trailing: 0)
        case .quote:
            return .init(top: 10, leading: 0, bottom: 10, trailing: 0)
        case .callout:
            return .init(top: 16, leading: 0, bottom: 16, trailing: 0)
        default:
            return .init(top: 4, leading: 0, bottom: 4, trailing: 0)
        }
    }
}
