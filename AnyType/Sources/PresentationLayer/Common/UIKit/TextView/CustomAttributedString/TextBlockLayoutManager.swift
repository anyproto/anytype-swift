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
        let characterRange = self.characterRange(forGlyphRange: glyphsToShow,
                                                 actualGlyphRange: nil)
        textStorage?.enumerateAttribute(.font,
                                        in: characterRange,
                                        using: { [weak self] value, subrange, _ in
            // In case we found code font we should also will draw code background
            guard let font = value as? UIFont,
                    font.fontName == UIFont.codeFont.fontName else { return }
            let targetRange = glyphRange(forCharacterRange: subrange, actualCharacterRange: nil)
            self?.drawCodeBackground(forGlyphRange: targetRange, color: UIColor.lightColdgray, origin: origin)
        })
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
    }
    
    private func drawCodeBackground(forGlyphRange glyphRange: NSRange, color: UIColor, origin: CGPoint) {
        guard let textContainer = textContainer(forGlyphAt: glyphRange.location,
                                                effectiveRange: nil) else { return }
        let withinRange = NSRange(location: NSNotFound, length: 0)
        enumerateEnclosingRects(forGlyphRange: glyphRange,
                                withinSelectedGlyphRange: withinRange,
                                in: textContainer) { rect, _ in
            let targetRect = rect.offsetBy(dx: origin.x, dy: origin.y)
            color.setFill()
            UIBezierPath(roundedRect: targetRect, cornerRadius: 4).fill()
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
