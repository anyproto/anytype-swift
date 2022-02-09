import SwiftUI

struct TextRelationView {
    let value: String?
    let hint: String
    let style: RelationStyle
    var allowMultiLine: Bool = false


    var swiftUI: some View {
        return TextRelationViewSwiftUI(text: text, style: style, allowMultiLine: allowMultiLine, hint: hint)
    }

    var uiKit: UIView {
        return TextRelationViewUIKit(text: text, hint: hint, style: style, allowMultiLine: allowMultiLine)
    }

    private var text: String? {
        if let maxLength = maxLength, let value = value, value.count > maxLength {
            return String(value.prefix(maxLength) + " ...")
        } else {
            return value
        }
    }

    private var maxLength: Int? {
        switch style {
        case .regular, .set: return nil
        case .featuredRelationBlock: return 40
        }
    }
}
