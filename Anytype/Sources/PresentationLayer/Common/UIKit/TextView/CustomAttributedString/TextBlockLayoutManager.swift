//
//  TextBlockLayoutManager.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

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
        
        let hasForegroundColor = !attributes[.foregroundColor].isNil
        if let color = obtainCustomFontColor(hasForegroundColor: hasForegroundColor) {
            CGContext.setFillColor(color)
        }

        super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, textMatrix: textMatrix, attributes: attributes, in: CGContext)
    }
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        let characterRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        drawUnderline(
            for: .mention,
            characterRange: characterRange,
            origin: origin
        )
        drawUnderline(
            for: .link,
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
                drawUnderline(forGlyphRange: glyphRange, origin: origin)
            })
    }
         
    private func drawUnderline(forGlyphRange glyphRange: NSRange, origin: CGPoint) {
        guard let textContainer = textContainer(forGlyphAt: glyphRange.location,
                                                effectiveRange: nil) else { return }
        let withinRange = NSRange(location: NSNotFound, length: 0)
        enumerateEnclosingRects(forGlyphRange: glyphRange,
                                withinSelectedGlyphRange: withinRange,
                                in: textContainer) { rect, _ in
            let textRect = rect.offsetBy(dx: origin.x, dy: origin.y)
            UIColor.textPrimary.setFill()
            UIBezierPath(rect: CGRect(origin: CGPoint(x: textRect.minX,
                                                      y: textRect.maxY),
                                      size: CGSize(width: textRect.width,
                                                   height: 1))).fill()
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
