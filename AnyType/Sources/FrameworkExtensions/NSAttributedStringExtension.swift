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
        guard length > 0 else { return false }
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

    /// Check if string has attribute
    /// - Parameters:
    ///   - attributeKey: attributed that we check
    ///   - range: attributed range
    /// - Returns: true if attribute founded otherweise false
    func hasAttribute(_ attributeKey: NSAttributedString.Key, at range: NSRange) -> Bool {
        guard length > 0 else { return false }
        
        let attributeValue = attribute(
            attributeKey,
            at: range.location,
            longestEffectiveRange: nil,
            in: range
        )
        
        return !attributeValue.isNil
    }
    
    /// Add plain string to attributed string and apply all attributes in range of all current string to plain string
    ///
    /// - Parameters:
    ///  - string: String to append
    ///
    /// - Returns: New attributed string
    func attributedStringByAppending(_ string: String) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        let currentStringRange = NSRange(location: 0, length: self.string.count)
        let stringToAppend = NSMutableAttributedString(string: string)
        let stringToAppendRange = NSRange(location: 0, length: string.count)
        enumerateAttributes(in: currentStringRange) { attributes, range, _ in
            guard range == currentStringRange else { return }
            stringToAppend.addAttributes(attributes, range: stringToAppendRange)
        }
        let mutableString = NSMutableAttributedString(attributedString: self)
        mutableString.append(stringToAppend)
        return NSAttributedString(attributedString: mutableString)
    }
}
