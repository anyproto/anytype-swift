import UIKit
import AnytypeCore
import Services

final class UIKitAnytypeText: Hashable {
    private let paragraphStyle: NSParagraphStyle
    private let textModifier: MarkStyleModifier
    
    let anytypeFont: AnytypeFont
    let attrString: NSMutableAttributedString
    let lineBreakModel: NSLineBreakMode
    
    init(
        attributedString: NSAttributedString,
        style: AnytypeFont,
        lineBreakModel: NSLineBreakMode
    ) {
        self.anytypeFont = style
        let font = UIKitFontBuilder.uiKitFont(font: style)
        
        let newAttrString = NSMutableAttributedString(attributedString: attributedString)
        textModifier = MarkStyleModifier(attributedString: newAttrString, anytypeFont: style)
                
        let paragraphStyle = TextDirection.paragraphStyle(for: attributedString.string)
        
        paragraphStyle.lineSpacing = style.lineSpacing
        paragraphStyle.lineBreakMode = lineBreakModel
        
        let range = NSMakeRange(0, newAttrString.length)
        newAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        // set kern
        newAttrString.addAttribute(.kern, value: style.config.kern, range: range)
        newAttrString.addAttribute(.font, value: font, range: range)
        
        attrString = newAttrString
        self.paragraphStyle = paragraphStyle
        self.lineBreakModel = lineBreakModel
    }
    
    func typingAttributes(for cursorPosition: Int) -> [NSAttributedString.Key : Any] {
        // setup typingAttributes
        let font: UIFont
        let indexBeforeCursor = cursorPosition - 1
        
        if indexBeforeCursor >= 0, indexBeforeCursor < attrString.length {
            font = (attrString.attribute(.font, at: indexBeforeCursor, effectiveRange: nil) as? UIFont) ?? anytypeFont.uiKitFont
        } else {
            font = anytypeFont.uiKitFont
        }
        
        return [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .kern: anytypeFont.config.kern
        ]
    }
    
    var verticalSpacing: CGFloat {
        anytypeFont.lineSpacing / 2
    }
    
    func apply(_ action: MarkupType, range: NSRange) {
        textModifier.apply(action, shouldApplyMarkup: true , range: range)
    }
    
    func appendSpace() {
        attrString.append(.init(string: " ", attributes: typingAttributes(for: .zero)))
    }
    
    static func == (lhs: UIKitAnytypeText, rhs: UIKitAnytypeText) -> Bool {
        lhs.attrString == rhs.attrString
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(attrString)
    }
}

extension UIKitAnytypeText {
    convenience init(
        text: String,
        style: AnytypeFont,
        lineBreakModel: NSLineBreakMode
    ) {
        self.init(
            attributedString: NSAttributedString(string: text),
            style: style,
            lineBreakModel: lineBreakModel
        )
    }
}
