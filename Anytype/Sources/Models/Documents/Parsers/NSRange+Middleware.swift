import ProtobufMessages
import Foundation

extension NSRange {
    init(_ range: Anytype_Model_Range) {
        self.init(
            location: Int(range.from),
            length: Int(range.to) - Int(range.from)
        )
    }
    
    var asMiddleware: Anytype_Model_Range {
        Anytype_Model_Range(
            from: Int32(lowerBound),
            to: Int32(lowerBound + length)
        )
    }
}
