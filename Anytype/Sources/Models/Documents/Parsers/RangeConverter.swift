import ProtobufMessages

enum RangeConverter {
    
    static func asModel(_ range: Anytype_Model_Range) -> NSRange {
        NSRange(
            location: Int(range.from),
            length: Int(range.to) - Int(range.from)
        )
    }
    
    static func asMiddleware(_ range: NSRange) -> Anytype_Model_Range {
        Anytype_Model_Range(
            from: Int32(range.lowerBound),
            to: Int32(range.lowerBound + range.length)
        )
    }
}
