//
//  TextBlockLayoutManager.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


extension NSAttributedString.Key {
    /// Block color attribute key
    static let blockColor = NSAttributedString.Key("BlockColor")
}

/// Custom layout manager for text block.
///
/// We can use this for drawing custom attributed key.
final class TextBlockLayoutManager: NSLayoutManager {

    override func showCGGlyphs(_ glyphs: UnsafePointer<CGGlyph>, positions: UnsafePointer<CGPoint>, count glyphCount: Int, font: UIFont, textMatrix: CGAffineTransform, attributes: [NSAttributedString.Key : Any] = [:], in CGContext: CGContext) {
        let blockColor = attributes[.blockColor]

        if let blockColor = blockColor as? UIColor, attributes[.foregroundColor] == nil {
            CGContext.setFillColor(blockColor.cgColor)
        }
        super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, textMatrix: textMatrix, attributes: attributes, in: CGContext)
    }
}
