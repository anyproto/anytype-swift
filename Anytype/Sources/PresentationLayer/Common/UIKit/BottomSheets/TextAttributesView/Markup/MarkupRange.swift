import Foundation

enum MarkupRange {
    case range(NSRange)
    case whole
    
    func range(for attributedString: NSAttributedString) -> NSRange {
        switch self {
        case .whole:
            return NSRange(location: 0, length: attributedString.length)
        case let .range(range):
            return range
        }
    }
}
