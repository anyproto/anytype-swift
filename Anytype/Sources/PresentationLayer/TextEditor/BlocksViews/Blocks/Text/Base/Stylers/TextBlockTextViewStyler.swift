import UIKit
import Services

final class TextBlockTextViewStyler {
    static func applyStyle(textView: CustomTextView, configuration: TextBlockContentConfiguration, restrictions: BlockRestrictions) {
        updateText(textView: textView, configuration: configuration)
        
        textView.autocorrect = configuration.content.contentType == .title ? false : true
        
        textView.textView.tertiaryColor = configuration.content.color.map { UIColor.Dark.uiColor(from: $0) }
        textView.textView.textAlignment = configuration.alignment
        
        textView.textView.selectedColor = nil
        if configuration.content.contentType == .checkbox {
            textView.textView.selectedColor = configuration.content.checked ? UIColor.Text.secondary : nil
        }
    }
    
    private static func updateText(textView: CustomTextView, configuration: TextBlockContentConfiguration) {
        switch configuration.content.contentType {
        case .title:
            setupText(in: textView, placeholer: Loc.untitled, textStyle: configuration.content.anytypeText)
        case .description:
            setupText(in: textView, placeholer: Loc.addADescription, textStyle: configuration.content.anytypeText)
        case .toggle:
            setupText(in: textView, placeholer: Loc.toggleBlock, textStyle: configuration.content.anytypeText)
        case .bulleted:
            setupText(in: textView, placeholer: Loc.bulletedPlaceholder, textStyle: configuration.content.anytypeText)
        case .checkbox:
            setupText(in: textView, placeholer: Loc.checkbox, textStyle: configuration.content.anytypeText)
        case .numbered:
            setupText(in: textView, placeholer: Loc.numberedPlaceholder, textStyle: configuration.content.anytypeText)
        case .quote:
            setupText(in: textView, placeholer: Loc.highlightedText, textStyle: configuration.content.anytypeText)
        case .header:
            setupText(in: textView, placeholer: Loc.title, textStyle: configuration.content.anytypeText)
        case .header2:
            setupText(in: textView, placeholer: Loc.heading, textStyle: configuration.content.anytypeText)
        case .header3:
            setupText(in: textView, placeholer: Loc.subheading, textStyle: configuration.content.anytypeText)
        case .header4, .code, .text, .callout:
            setupText(in: textView, placeholer: "", textStyle: configuration.content.anytypeText)
        }
    }
    
    private static func setupText(in textView: CustomTextView, placeholer: String, textStyle: UIKitAnytypeText) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: textStyle.anytypeFont.uiKitFont,
            .foregroundColor: UIColor.Text.secondary,
        ]

        textView.textView.update(placeholder: .init(string: placeholer, attributes: attributes))
        textView.textView.textContainerInset = .init(
            top: textStyle.verticalSpacing,
            left: 0,
            bottom: textStyle.verticalSpacing,
            right: 0
        )

        // setup typingAttributes
        if let selectedRange = textView.textView.selectedTextRange {
            let cursorPosition = textView.textView.offset(from: textView.textView.beginningOfDocument, to: selectedRange.start)
            textView.textView.typingAttributes = textStyle.typingAttributes(for: cursorPosition)
        } else {
            textView.textView.typingAttributes = textStyle.typingAttributes(for: 0)
        }

        textView.textView.defaultFontColor = .Text.primary
    }
}
