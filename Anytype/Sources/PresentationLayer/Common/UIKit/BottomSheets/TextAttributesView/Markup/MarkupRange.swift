import Foundation

enum MarkupRange {
    case range(NSRange)
    case whole
    
    func range(for attributedString: NSAttributedString) -> NSRange {
        switch self {
        case .whole:
            return attributedString.wholeRange
        case let .range(range):
            return range
        }
    }
}
