import Foundation

extension String {
    var wholeRange: NSRange {
        return NSRange(location: 0, length: count)
    }
    
    func distanceFromTheBegining(to index: Index) -> String.IndexDistance {
        distance(from: startIndex, to: index)
    }
}

extension NSAttributedString {
    var wholeRange: NSRange {
        return NSRange(location: 0, length: length)
    }
}
