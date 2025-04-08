import SwiftProtobuf
import CoreMedia

public protocol ProtobufValueProvider {
    var protobufValue: Google_Protobuf_Value { get }
}

extension String: ProtobufValueProvider {
    public var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(stringValue: self)
    }
}

extension Int: ProtobufValueProvider {
    public var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(numberValue: Double(self))
    }
}

extension Double: ProtobufValueProvider {
    public var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(numberValue: self)
    }
}

extension Bool: ProtobufValueProvider {
    public var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(boolValue: self)
    }
}

extension Date: ProtobufValueProvider {
    public var protobufValue: Google_Protobuf_Value {
        // Cast to int to remove decimal part for middleware
        Google_Protobuf_Value(integerLiteral: Int64(timeIntervalSince1970))
    }
}
 
extension Array: ProtobufValueProvider where Element: ProtobufValueProvider {
    public var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(
            listValue: Google_Protobuf_ListValue(
                values: self.map { $0.protobufValue }
            )
        )
    }
}

extension Dictionary: ProtobufValueProvider where Key == String, Value == Google_Protobuf_Value {
    public var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(
            structValue: Google_Protobuf_Struct(
                fields: self
            )
        )
    }
}
