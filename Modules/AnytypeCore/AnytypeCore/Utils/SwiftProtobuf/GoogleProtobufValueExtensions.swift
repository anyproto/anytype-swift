import SwiftProtobuf

public extension Google_Protobuf_Value {
    
    var safeIntValue: Int? {
        guard let number = safeDoubleValue else { return nil }
        return Int(number)
    }
    
    var safeDoubleValue: Double? {
        let number = numberValue
        guard !number.isNaN else { return nil }
        
        return number
    }
    
}
