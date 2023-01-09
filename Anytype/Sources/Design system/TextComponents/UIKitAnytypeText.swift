import UIKit
import AnytypeCore

final class UIKitAnytypeText: Hashable {
    private let paragraphStyle: NSParagraphStyle
    private let textModifier: MarkStyleModifier

    let anytypeFont: AnytypeFont
    let attrString: NSAttributedString
    let lineBreakModel: NSLineBreakMode

    convenience init(text: String, style: AnytypeFont, lineBreakModel: NSLineBreakMode = .byTruncatingTail) {
        self.init(attributedString: NSAttributedString(string: text), style: style, lineBreakModel: lineBreakModel)
    }

    init(attributedString: NSAttributedString, style: AnytypeFont, lineBreakModel: NSLineBreakMode = .byTruncatingTail) {
        self.anytypeFont = style
        let font = UIKitFontBuilder.uiKitFont(font: style)

        let newAttrString = NSMutableAttributedString(attributedString: attributedString)
        textModifier = MarkStyleModifier(attributedString: newAttrString, anytypeFont: style)

        // setup line height
        
        let paragraphStyle = attributedString.length > 0
            ? (attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
            : NSMutableParagraphStyle()

        paragraphStyle.lineSpacing = style.lineSpacing
        paragraphStyle.lineBreakMode = lineBreakModel
        
        let range = NSMakeRange(0, newAttrString.length)
        newAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)

        // set kern
        newAttrString.addAttribute(.kern, value: style.kern, range: range)
        newAttrString.addAttribute(.font, value: font, range: range)

        attrString = newAttrString
        self.paragraphStyle = paragraphStyle
        self.lineBreakModel = lineBreakModel
    }

    func typingAttributes(for cursorPosition: Int) -> [NSAttributedString.Key : Any] {
        // setup typingAttributes
        if cursorPosition == .zero {
            return [
                .font: anytypeFont.uiKitFont,
                .paragraphStyle: paragraphStyle,
                .kern: anytypeFont.kern
            ]
        } else {
            let characterBeforeCursor = cursorPosition - 1
            let font = (attrString.attribute(.font, at: characterBeforeCursor, effectiveRange: nil) as? UIFont) ?? anytypeFont.uiKitFont
            return [.font: font, .paragraphStyle: paragraphStyle]
        }
    }

    var verticalSpacing: CGFloat {
        anytypeFont.lineSpacing / 2
    }

    func apply(_ action: MarkupType, range: NSRange) {
        textModifier.apply(action, shouldApplyMarkup: true , range: range)
    }

    static func == (lhs: UIKitAnytypeText, rhs: UIKitAnytypeText) -> Bool {
        lhs.attrString == rhs.attrString
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(attrString)
    }
}
