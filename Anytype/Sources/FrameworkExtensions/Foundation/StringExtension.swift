import Foundation

extension String {
    var wholeRange: NSRange {
        return NSRange(location: 0, length: count)
    }
}

extension NSAttributedString {
    var wholeRange: NSRange {
        return NSRange(location: 0, length: length)
    }
}
