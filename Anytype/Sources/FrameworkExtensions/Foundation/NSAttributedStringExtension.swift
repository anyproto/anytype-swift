import UIKit


extension NSAttributedString {
    
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
    
    /// Get value by attribute in attributed string
    ///
    /// Example: value exists in rangeWithValue (0, 5)
    /// Will return true if rangeWithValue contains range
    /// Will return false otherwise
    ///
    /// - Parameters:
    ///   - attributeKey: Key by which to search value for
    ///   - range: Range at which to search value for
    /// - Returns: Returns non nil value only if it exists in a whole passed range
    func value<Result>(for attributeKey: NSAttributedString.Key, range: NSRange) -> Result? {
        guard isRangeValid(range) else { return nil }
        var longestRange = NSRange()
        let value = attribute(
            attributeKey,
            at: range.location,
            longestEffectiveRange: &longestRange,
            in: range
        )
        guard let intersection = longestRange.intersection(range),
              intersection == range else {
            return nil
        }
        return value as? Result
    }
    
    func isRangeValid(_ range: NSRange) -> Bool {
        length > 0 && length >= range.length + range.location && range.location >= 0
    }
    
    func rangesWith(attribute: Key) -> [NSRange]? {
        guard length > 0 else { return nil }
        var ranges = [NSRange]()
        enumerateAttribute(
            attribute,
            in: NSRange(location: 0, length: length)
        ) { value, subrange, _ in
            guard attribute.checkValue(value) else { return }
            ranges.append(subrange)
        }
        return ranges
    }
}
