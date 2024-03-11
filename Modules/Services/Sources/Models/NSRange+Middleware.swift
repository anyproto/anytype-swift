import ProtobufMessages
import Foundation

public extension NSRange {
    init(_ range: Anytype_Model_Range) {
        self.init(
            location: Int(range.from),
            length: Int(range.to) - Int(range.from)
        )
    }
    
    var asMiddleware: Anytype_Model_Range {
        Anytype_Model_Range.with {
            $0.from = Int32(lowerBound)
            $0.to = Int32(lowerBound + length)
        }
    }
}
