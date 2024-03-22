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
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Title.placeholder, configuration: configuration)
        case .description:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Description.placeholder, configuration: configuration)
        case .toggle:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Toggle.placeholder, configuration: configuration)
        case .bulleted:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Bulleted.placeholder, configuration: configuration)
        case .checkbox:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Checkbox.placeholder, configuration: configuration)
        case .numbered:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Numbered.placeholder, configuration: configuration)
        case .quote:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Quote.placeholder, configuration: configuration)
        case .header:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Header.placeholder, configuration: configuration)
        case .header2:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Header2.placeholder, configuration: configuration)
        case .header3:
            setupText(in: textView, placeholer: Loc.BlockText.ContentType.Header3.placeholder, configuration: configuration)
        case .header4, .code, .text, .callout:
            setupText(in: textView, placeholer: "", configuration: configuration)
        }
    }
    
    private static func setupText(
        in textView: CustomTextView,
        placeholer: String,
        configuration: TextBlockContentConfiguration
    ) {
        textView.textView.update(placeholder: .init(string: placeholer, attributes: configuration.placeholderAttributes))
        textView.textView.textContainerInset = configuration.textContainerInsets
        textView.textView.defaultFontColor = .Text.primary
        
        if let selectedRange = textView.textView.selectedTextRange {
            let cursorPosition = textView.textView.offset(from: textView.textView.beginningOfDocument, to: selectedRange.start)
            textView.textView.typingAttributes = configuration.typingAttributes(cursorPosition)
        } else {
            textView.textView.typingAttributes = configuration.typingAttributes(0)
        }
    }
}
