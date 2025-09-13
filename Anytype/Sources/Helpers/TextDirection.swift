import UIKit

enum TextDirection {
    static func isRTL(_ text: String) -> Bool {
        // Detect Arabic (and optionally extend with other RTL scripts if needed)
        return text.range(of: "\\p{Arabic}", options: .regularExpression) != nil
    }

    static func paragraphStyle(for text: String) -> NSMutableParagraphStyle {
        let style = NSMutableParagraphStyle()
        if isRTL(text) {
            style.baseWritingDirection = .rightToLeft
        } else {
            style.baseWritingDirection = .leftToRight
        }
        style.alignment = .natural
        return style
    }

    static func alignment(for text: String) -> NSTextAlignment {
        .natural
    }
}
