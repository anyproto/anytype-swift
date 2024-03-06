import Foundation

extension NSRange {
    static var zero: NSRange {
        NSRange(location: 0, length: 0)
    }
    
    var centerIndex: Int {
        return location + length / 2
    }
}
