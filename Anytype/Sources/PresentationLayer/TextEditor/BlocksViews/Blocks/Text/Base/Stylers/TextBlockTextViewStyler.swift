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
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Title.placeholder, textStyle: configuration.anytypeText)
        case .description:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Description.placeholder, textStyle: configuration.anytypeText)
        case .toggle:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Toggle.placeholder, textStyle: configuration.anytypeText)
        case .bulleted:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Bulleted.placeholder, textStyle: configuration.anytypeText)
        case .checkbox:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Checkbox.placeholder, textStyle: configuration.anytypeText)
        case .numbered:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Numbered.placeholder, textStyle: configuration.anytypeText)
        case .quote:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Quote.placeholder, textStyle: configuration.anytypeText)
        case .header:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Header.placeholder, textStyle: configuration.anytypeText)
        case .header2:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Header2.placeholder, textStyle: configuration.anytypeText)
        case .header3:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Header3.placeholder, textStyle: configuration.anytypeText)
        case .header4, .code, .text, .callout:
            setupText(in: textView, placeholer: "", textStyle: configuration.anytypeText)
        }
    }
    
    private static func setupText(in textView: CustomTextView, placeholer: String, textStyle: UIKitAnytypeText) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: textStyle.anytypeFont.uiKitFont,
            .foregroundColor: UIColor.Text.tertiary,
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
