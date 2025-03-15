import SwiftProtobuf
import CoreMedia

public extension String {
    var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(stringValue: self)
    }
}

public extension Int {
    var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(numberValue: Double(self))
    }
}

public extension Double {
    var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(numberValue: self)
    }
}

public extension Bool {
    var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(boolValue: self)
    }
}

public extension Date {
    var protobufValue: Google_Protobuf_Value {
        // Cast to int to remove decimal part for middleware
        Google_Protobuf_Value(integerLiteral: Int64(timeIntervalSince1970))
    }
}

public extension Array where Element == String {
    var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(
            listValue: Google_Protobuf_ListValue(
                values: self.map { $0.protobufValue }
            )
        )
    }
}

public extension Array where Element == Int {
    var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(
            listValue: Google_Protobuf_ListValue(
                values: self.map { $0.protobufValue }
            )
        )
    }
}

public extension Dictionary where Key == String, Value == Google_Protobuf_Value {
    var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(
            structValue: Google_Protobuf_Struct(
                fields: self
            )
        )
    }
}
