import UIKit
import BlocksModels

final class TextBlockTextViewStyler {
    static func applyStyle(textView: CustomTextView, configuration: TextBlockContentConfiguration) {
        updateText(textView: textView, configuration: configuration)
        
        textView.textView.tertiaryColor = configuration.content.color?.color(background: false)
        textView.textView.textAlignment = configuration.information.alignment.asNSTextAlignment
    }
    
    private static func updateText(textView: CustomTextView, configuration: TextBlockContentConfiguration) {
        switch configuration.content.contentType {
        case .title:
            setupText(in: textView, placeholer: "Untitled".localized, textStyle: configuration.text)
        case .description:
            setupText(in: textView, placeholer: "Add a description".localized, textStyle: configuration.text)
        case .toggle:
            setupText(in: textView, placeholer: "Toggle block".localized, textStyle: configuration.text)
        case .bulleted:
            setupText(in: textView, placeholer: "Bulleted placeholder".localized, textStyle: configuration.text)
        case .checkbox:
            setupText(in: textView, placeholer: "Checkbox".localized, textStyle: configuration.text)
        case .numbered:
            setupText(in: textView, placeholer: "Numbered placeholder".localized, textStyle: configuration.text)
        case .quote:
            setupText(in: textView, placeholer: "Quote".localized, textStyle: configuration.text)
        case .header:
            setupText(in: textView, placeholer: "Title".localized, textStyle: configuration.text)
        case .header2:
            setupText(in: textView, placeholer: "Heading".localized, textStyle: configuration.text)
        case .header3:
            setupText(in: textView, placeholer: "Subheading".localized, textStyle: configuration.text)
        case .header4, .code, .text:
            setupText(in: textView, placeholer: "", textStyle: configuration.text)
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
