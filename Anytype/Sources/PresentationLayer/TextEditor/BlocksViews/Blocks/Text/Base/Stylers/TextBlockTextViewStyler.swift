import UIKit
import BlocksModels

final class TextBlockTextViewStyler {
    static func applyStyle(textView: CustomTextView, style: BlockText.Style, textStyle: UIKitAnytypeText) {
        switch style {
        case .title:
            setupText(in: textView, placeholer: "Untitled".localized, textStyle: textStyle)
        case .description:
            setupText(in: textView, placeholer: "Add a description".localized, textStyle: textStyle)
        case .toggle:
            setupText(in: textView, placeholer: "Toggle block".localized, textStyle: textStyle)
        case .bulleted:
            setupText(in: textView, placeholer: "Bulleted placeholder".localized, textStyle: textStyle)
        case .checkbox:
            setupText(in: textView, placeholer: "Checkbox".localized, textStyle: textStyle)
        case .numbered:
            setupText(in: textView, placeholer: "Numbered placeholder".localized, textStyle: textStyle)
        case .quote:
            setupText(in: textView, placeholer: "Quote".localized, textStyle: textStyle)
        case .header:
            setupText(in: textView, placeholer: "Title".localized, textStyle: textStyle)
        case .header2:
            setupText(in: textView, placeholer: "Heading".localized, textStyle: textStyle)
        case .header3:
            setupText(in: textView, placeholer: "Subheading".localized, textStyle: textStyle)
        case .header4, .code, .text:
            setupText(in: textView, placeholer: "", textStyle: textStyle)
        }
    }
    
    private static func setupText(in textView: CustomTextView, placeholer: String, textStyle: UIKitAnytypeText) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: textStyle.font,
            .foregroundColor: UIColor.textSecondary,
        ]

        textView.textView.update(placeholder: .init(string: placeholer, attributes: attributes))
        textView.textView.textContainerInset = .init(
            top: textStyle.verticalSpacing,
            left: 0,
            bottom: textStyle.verticalSpacing,
            right: 0
        )

        textView.textView.typingAttributes = textStyle.typingAttributes
        textView.textView.defaultFontColor = .textPrimary
    }
}
