import Foundation
import Services

extension NSAttributedString {
    func rangeWithoutMention(_ initialRange: NSRange) -> NSRange {
        var newRange = initialRange
        
        enumerateAttribute(.mention, in: self.wholeRange) { value, subrange, shouldStop in
            guard value.isNotNil else { return }
            
            if subrange.lowerBound < initialRange.lowerBound { // removing mentions icons to the left
                newRange = NSRange(location: newRange.lowerBound - 1, length: newRange.length)
            }
        }
        
        guard isRangeValid(newRange) else {
            return initialRange
        }
        
        return newRange
    }
}

extension BlockText {
    var endOfTextRangeWithMention: NSRange {
        let numberOfMentions = marks.marks.filter { $0.type == .mention }.count
        return NSRange(location: text.count + numberOfMentions, length: 0)
    }
}
