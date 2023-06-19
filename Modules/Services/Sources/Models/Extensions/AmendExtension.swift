import ProtobufMessages
import SwiftProtobuf

public extension Array where Element == Anytype_Event.Object.Details.Amend.KeyValue {

    var asDetailsDictionary: [String: Google_Protobuf_Value] {
        reduce(
            into: [String: Google_Protobuf_Value]()
        ) { result, detail in
            result[detail.key] = detail.value
        }
    }
}
