import SwiftUI

struct TextRelationFactory {

    static func swiftUI(value: String?, hint: String, style: RelationStyle) -> some View {
        let maxLength = maxLength(style: style)
        let text = TextRelationFactory.text(value: value, maxLength: maxLength)
        return TextRelationViewSwiftUI(text: text, style: style, hint: hint)
    }

    static func uiKit(value: String?, hint: String, style: RelationStyle) -> UIView {
        let maxLength = maxLength(style: style)
        let text = TextRelationFactory.text(value: value, maxLength: maxLength)
        
        guard let text = text else {
            return RelationPlaceholderViewUIKit(hint: hint, type: .hint)
        }
        
        return TextRelationViewUIKit(text: text, style: style)
    }

    private static func text(value: String?, maxLength: Int?) -> String? {
        if let maxLength = maxLength, let value = value, value.count > maxLength {
            return String(value.prefix(maxLength) + " ...")
        } else {
            return value
        }
    }

    private static func maxLength(style: RelationStyle) -> Int? {
        switch style {
        case .regular, .set: return nil
        case .featuredRelationBlock: return 40
        }
    }
}
