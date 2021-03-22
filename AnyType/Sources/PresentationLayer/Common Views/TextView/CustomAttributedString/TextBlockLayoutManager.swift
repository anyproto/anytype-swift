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
/// We can use this for drawing custom attributed key.
final class TextBlockLayoutManager: NSLayoutManager {
    /// Main color.
    ///
    /// Custom color that applyed before `foregroundColor`and `thirdColor`
    var primaryColor: UIColor?
    /// Third priority color.
    ///
    /// Custom color that applyed after `primaryColor`and `foregroundColor`
    var tertiaryColor: UIColor?

    override func showCGGlyphs(_ glyphs: UnsafePointer<CGGlyph>, positions: UnsafePointer<CGPoint>, count glyphCount: Int, font: UIFont, textMatrix: CGAffineTransform, attributes: [NSAttributedString.Key : Any] = [:], in CGContext: CGContext) {

        if let color = obtainCustomFontColor(hasForegroundColor: attributes[.foregroundColor] != nil) {
            CGContext.setFillColor(color)
        }

        super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, textMatrix: textMatrix, attributes: attributes, in: CGContext)
    }

    private func obtainCustomFontColor(hasForegroundColor: Bool) -> CGColor? {
        var color: CGColor?

        if let primaryColor = primaryColor {
            color = primaryColor.cgColor
        }
        else if let thirdColor = tertiaryColor, !hasForegroundColor {
            color = thirdColor.cgColor
        }
        return color
    }
}
