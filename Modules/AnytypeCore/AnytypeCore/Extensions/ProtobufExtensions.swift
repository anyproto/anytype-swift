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
