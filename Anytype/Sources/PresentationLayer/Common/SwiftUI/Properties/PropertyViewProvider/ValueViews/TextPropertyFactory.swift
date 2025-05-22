import SwiftUI

struct TextPropertyFactory {

    static func view(value: String?, hint: String, style: PropertyStyle) -> some View {
        let maxLength = maxLength(style: style)
        let text = TextPropertyFactory.text(value: value, maxLength: maxLength)
        return TextPropertyView(text: text, style: style, hint: hint)
    }

    static func text(value: String?, maxLength: Int?) -> String? {
        if let maxLength = maxLength, let value = value, value.count > maxLength {
            return String(value.prefix(maxLength) + "...")
        } else {
            return value
        }
    }

    static func maxLength(style: PropertyStyle) -> Int? {
        switch style {
        case .regular, .set, .filter, .setCollection, .kanbanHeader: return nil
        case .featuredBlock: return 40
        }
    }
}
