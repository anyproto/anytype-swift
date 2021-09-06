import SwiftProtobuf

public extension Google_Protobuf_Value {
    
    var safeIntValue: Int? {
        guard
            case let .numberValue(number) = kind,
            !number.isNaN
        else {
            return nil
        }
        
        return Int(number)
    }
    
}
