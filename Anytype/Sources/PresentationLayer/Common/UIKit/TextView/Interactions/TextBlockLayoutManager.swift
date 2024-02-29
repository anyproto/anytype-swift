import UIKit
import AnytypeCore

/// Custom layout manager for text block.
///
/// We can use this for drawing custom attributed key, color or other text styles.
/// - Note: `foregroundColor` from `NSAttributedString.Key` applied as secondary color.
final class TextBlockLayoutManager: NSLayoutManager {
    /// Main color.
    ///
    /// Custom color that applyed before `foregroundColor`and `thirdColor`
    var primaryColor: UIColor?

    /// Third priority color.
    ///
    /// Custom color that applyed after `primaryColor`and `foregroundColor`
    var tertiaryColor: UIColor?

    /// Default color.
    ///
    /// The lowest priority color.  Applied when either `primaryColor`, `foregroundColor` and `tertiaryColor` haven't set. Default value is `black`.
    var defaultColor: UIColor?

    override func showCGGlyphs(_ glyphs: UnsafePointer<CGGlyph>, positions: UnsafePointer<CGPoint>, count glyphCount: Int, font: UIFont, textMatrix: CGAffineTransform, attributes: [NSAttributedString.Key : Any] = [:], in CGContext: CGContext) {
        
        let hasForegroundColor = attributes[.foregroundColor].isNotNil
        if let color = obtainCustomFontColor(hasForegroundColor: hasForegroundColor) {
            CGContext.setFillColor(color)
        }
        
        super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, textMatrix: textMatrix, attributes: attributes, in: CGContext)
    }
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        let characterRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        drawUnderline(
            for: .anytypeLink,
            characterRange: characterRange,
            origin: origin
        )
        
        drawUnderline(
            for: .link,
            characterRange: characterRange,
            origin: origin
        )
        
        drawUnderline(
            for: .anytypeUnderline,
            characterRange: characterRange,
            origin: origin
        )
        
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
    }
    
    private func drawUnderline(
        for attribute: NSAttributedString.Key,
        characterRange: NSRange,
        origin: CGPoint
    ) {
        textStorage?.enumerateAttribute(
            attribute,
            in: characterRange,
            options: .longestEffectiveRangeNotRequired,
            using: { value, subrange, _ in
                guard attribute.checkValue(value) else { return }
                let glyphRange = glyphRange(forCharacterRange: subrange, actualCharacterRange: nil)

                drawUnderline(
                    forGlyphRange: glyphRange,
                    origin: origin,
                    color: attribute.underlineColor(with: textColor(in: subrange)),
                    thinkness: attribute.underlineThickness
                )
            }
        )
    }

    private func textColor(in range: NSRange) -> UIColor {
        guard let attributedString = textStorage?.attributedSubstring(from: range) else {
            return primaryColor ?? tertiaryColor ?? .Text.primary
        }

        let textColor = attributedString.colorState(range: attributedString.wholeRange)

        if textColor == nil {
            return primaryColor ?? tertiaryColor ?? .Text.primary
        }

        if let tertiaryColor = tertiaryColor, textColor == .Text.primary && tertiaryColor != .Text.primary {
            return tertiaryColor
        }

        return textColor ?? .Text.primary
    }
         
    private func drawUnderline(
        forGlyphRange glyphRange: NSRange,
        origin: CGPoint,
        color: UIColor,
        thinkness: CGFloat
    ) {
        guard let textContainer = textContainer(forGlyphAt: glyphRange.location,
                                                effectiveRange: nil) else { return }

        enumerateLineFragments(forGlyphRange: glyphRange) { [weak self] _, _, _, glyphRangeInLine, _ in

            guard let glyphRangeWithAttribute = glyphRangeInLine.intersection(glyphRange) else { return }
            guard let rect = self?.boundingRect(forGlyphRange: glyphRangeWithAttribute, in: textContainer) else { return }

            guard let font = self?.textStorage?.attribute(
                .font,
                at: glyphRange.centerIndex,
                effectiveRange: nil
            ) as? UIFont else {
                anytypeAssertionFailure("font attribute must be UIFont")
                return
            }
            let rectRelatvieToFontHeight = CGRect(origin: rect.origin, size: .init(width: rect.width, height: font.lineHeight))
            let textRect = rectRelatvieToFontHeight.offsetBy(dx: origin.x, dy: origin.y)

            color.setFill()
            let lineHeight: CGFloat = thinkness

            // When size of the uitextview was reduced using negative textContainerInset values, underline should be moved upper to be visible.
            // Otherwise it will be outside the uitextview and not visible.
            var additionalYOffset: CGFloat = 0

            if origin.y < 0 {
                let font = self?.textStorage?.attribute(
                    .font,
                    at: glyphRange.centerIndex,
                    effectiveRange: nil
                ) as! UIFont
                // line should not be upper font descender otherwise smth wrong
                additionalYOffset = max(font.descender, origin.y) - lineHeight
            }

            UIBezierPath(rect: CGRect(origin: CGPoint(x: textRect.minX,
                                                      y: textRect.maxY + additionalYOffset - 2),
                                      size: CGSize(width: textRect.width,
                                                   height: lineHeight))).fill()
        }
    }
    
    private func obtainCustomFontColor(hasForegroundColor: Bool) -> CGColor? {
        if let primaryColor = primaryColor {
            return primaryColor.cgColor
        }

        if let thirdColor = tertiaryColor, !hasForegroundColor {
            return thirdColor.cgColor
        }

        if !hasForegroundColor {
            return defaultColor?.cgColor
        }
        return nil
    }
}

extension UIFont {
    var anytypeDescription: String {
        "\(description); pointSize: \(pointSize); capHeight: \(capHeight); xHeight: \(xHeight); ascender: \(ascender); descender: \(descender); lineHeight: \(lineHeight); leading: \(leading)"
    }
}

extension NSAttributedString.Key {
    func underlineColor(with textColor: UIColor) -> UIColor {
        switch self {
        case .anytypeLink:
            return textColor.withAlphaComponent(0.5)
        default:
            return textColor
        }
    }

    var underlineThickness: CGFloat {
        switch self {
        case .anytypeUnderline:
            return 0.5
        default:
            return 1
        }
    }
}
