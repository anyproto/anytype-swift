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
        guard isRangeValid(range) else { return false }
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
    
    func isFontInWhole(range: NSRange, has trait: UIFontDescriptor.SymbolicTraits) -> Bool {
        guard isRangeValid(range) else { return false }
        var result = true
        enumerateAttribute(
            .font,
            in: range) { value, _, shouldStop in
            guard let font = value as? UIFont else {
                result = false
                shouldStop[0] = true
                return
            }
            if !font.fontDescriptor.symbolicTraits.contains(trait) {
                result = false
                shouldStop[0] = true
            }
        }
        return result
    }

    /// Check if string has attribute
    /// - Parameters:
    ///   - attributeKey: attributed that we check
    ///   - range: attributed range
    /// - Returns: true if attribute founded otherweise false
    func hasAttribute(_ attributeKey: NSAttributedString.Key, at range: NSRange) -> Bool {
        guard isRangeValid(range) else { return false }
        
        let attributeValue = attribute(
            attributeKey,
            at: range.location,
            longestEffectiveRange: nil,
            in: range
        )
        
        return !attributeValue.isNil
    }
    
    func isEverySymbol(in range: NSRange, has attributeKey: Key) -> Bool {
        guard isRangeValid(range) else { return false }
        var result = true
        enumerateAttribute(attributeKey, in: range) { value, _, shouldStop in
            if value == nil {
                result = false
                shouldStop[0] = true
            }
        }
        return result
    }
    
    /// Add plain string to attributed string and apply all attributes in range of all current string to plain string
    ///
    /// - Parameters:
    ///  - string: String to append
    ///  - index: Index where to insert string
    ///  - attachmentAttributes: attributes to use in case we insert new string at index with attachment
    ///
    /// - Returns: New attributed string
    func attributedStringByInserting(_ string: String,
                                     at index: Int,
                                     attachmentAttributes: [NSAttributedString.Key: Any] = [:]) -> NSAttributedString {
        guard !string.isEmpty, index <= length else { return self }
        let attributesIndex = index == length ? index - 1 : index
        var attributesAtIndex = attributes(at: attributesIndex,
                                           effectiveRange: nil)
        if attributesAtIndex.keys.contains(.attachment) {
            attributesAtIndex = attachmentAttributes
        }
        let stringToInsert = NSAttributedString(string: string,
                                                attributes: attributesAtIndex)
        let mutableString = NSMutableAttributedString(attributedString: self)
        mutableString.insert(stringToInsert, at: index)
        return NSAttributedString(attributedString: mutableString)
    }
    
    /// Prefer this function over standard 'string'
    func clearedFromMentionAtachmentsString() -> String {
        let mutableCopy = NSMutableAttributedString(attributedString: self)
        mutableCopy.removeAllMentionAttachmets()
        return mutableCopy.string
    }
    
    func isCodeFontInWhole(range: NSRange) -> Bool {
        guard isRangeValid(range) else { return false }
        var result = true
        enumerateAttribute(
            .font,
            in: range
        ) { value, _, shouldStop in
            guard let font = value as? UIFont else {
                result = false
                shouldStop[0] = true
                return
            }
            if !font.isCode {
                result = false
                shouldStop[0] = true
            }
        }
        return result
    }
    
    private func isRangeValid(_ range: NSRange) -> Bool {
        length > 0 && length >= range.length && range.location >= 0
    }
}
