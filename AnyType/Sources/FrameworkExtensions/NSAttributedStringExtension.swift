//
//  NSAttributedStringExtension.swift
//  AnyType
//
//  Created by Батвинкин Денис Сергеевич on 10.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {

    /// Check if string has particular style at least for one symbol from range
    /// - Parameter range: range over which the style are checked
    /// - Returns: true if has given style otherwise false
    func hasTrait(trait: UIFontDescriptor.SymbolicTraits, at range: NSRange) -> Bool {
        var hasStyle = false

        enumerateAttribute(.font, in: range) { font, _, shouldStop in
            guard let font = font as? UIFont else { return }

            if font.fontDescriptor.symbolicTraits.contains(trait) {
                hasStyle = true
                shouldStop[0] = true
            }
        }
        return hasStyle
    }

    func hasAttribute(_ attributeKey: NSAttributedString.Key, at range: NSRange) -> Bool {
        attribute(attributeKey, at: range.location, longestEffectiveRange: nil, in: range) != nil
    }
}
