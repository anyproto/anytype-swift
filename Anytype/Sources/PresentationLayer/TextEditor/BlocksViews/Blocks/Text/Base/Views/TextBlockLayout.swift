import UIKit
import BlocksModels

enum TextBlockLayout {
    static func mainInset(textBlockStyle: BlockText.Style) -> NSDirectionalEdgeInsets {
        switch textBlockStyle {
        case .title:
            return .zero
        case .description:
            return .init(top: 8, leading: 0, bottom: 0, trailing: 0)
        case .header:
            return .init(top: 24, leading: 0, bottom: -2, trailing: 0)
        case .header2, .header3:
            return .init(top: 16, leading: 0, bottom: -2, trailing: 0)
        default:
            return .init(top: 0, leading: 0, bottom: -2, trailing: 0)
        }
    }

    static func contentInset(textBlockStyle: BlockText.Style) -> NSDirectionalEdgeInsets {
        switch textBlockStyle {
        case .title:
            return .zero
        case .description:
            return .zero
        case .header:
            return .init(top: 5, leading: 0, bottom: -5, trailing: 0)
        case .header2:
            return .init(top: 5, leading: 0, bottom: -5, trailing: 0)
        case .quote:
            return .init(top: 10, leading: 0, bottom: -10, trailing: 0)
        default:
            return .init(top: 4, leading: 0, bottom: -4, trailing: 0)
        }
    }
}
