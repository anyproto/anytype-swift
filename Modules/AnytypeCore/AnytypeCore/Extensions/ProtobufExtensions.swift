import SwiftProtobuf

public extension String {
    var protobufValue: Google_Protobuf_Value {
        Google_Protobuf_Value(stringValue: self)
    }
}
