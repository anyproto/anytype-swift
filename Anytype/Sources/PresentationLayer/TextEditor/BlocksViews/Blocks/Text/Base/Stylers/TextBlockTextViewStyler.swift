import UIKit
import BlocksModels

final class TextBlockTextViewStyler {
    static func applyStyle(textView: CustomTextView, configuration: TextBlockContentConfiguration, restrictions: BlockRestrictions) {
        updateText(textView: textView, configuration: configuration)
        updateContextMenu(textView: textView, restrictions: restrictions)
        updateCustomTextViewOptions(textView: textView, configuration: configuration, restrictions: restrictions)
        
        textView.textView.tertiaryColor = configuration.content.color?.color(background: false)
        textView.textView.textAlignment = configuration.information.alignment.asNSTextAlignment
        
        textView.textView.selectedColor = nil
        if configuration.content.contentType == .checkbox {
            textView.textView.selectedColor = configuration.content.checked ? UIColor.textSecondary : nil
        }
    }
    
    private static func updateCustomTextViewOptions(
        textView: CustomTextView,
        configuration: TextBlockContentConfiguration,
        restrictions: BlockRestrictions
    ) {
        let autocorrect = configuration.information.content.type == .text(.title) ? false : true
        let options = CustomTextViewOptions(
            createNewBlockOnEnter: restrictions.canCreateBlockBelowOnEnter,
            autocorrect: autocorrect
        )
        textView.setCustomTextViewOptions(options: options)
    }
    
    private static func updateContextMenu(textView: CustomTextView, restrictions: BlockRestrictions) {
        let allOptions = TextViewContextMenuOption.allCases
        let availableOptions = allOptions.filter { option -> Bool in
            switch option {
            case let .toggleMarkup(type):
                switch type {
                case .bold:
                    return restrictions.canApplyBold
                case .italic:
                    return restrictions.canApplyItalic
                case .strikethrough, .keyboard:
                    return restrictions.canApplyOtherMarkup
                }
            case .setLink:
                return restrictions.canApplyOtherMarkup
            }
        }
        textView.textView.availableContextMenuOptions = availableOptions
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
            setupText(in: textView, placeholer: "Highlighted text".localized, textStyle: configuration.text)
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
