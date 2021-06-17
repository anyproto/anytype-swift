import ProtobufMessages
import SwiftProtobuf


/// Middleware configuration
/// TODO: Move to BlockModels module.
struct MiddlewareConfiguration: Hashable {
    static var shared: Self?
    
    let homeBlockID: String
    let archiveBlockID: String
    let profileBlockId: String
    let gatewayURL: String
}

struct MiddlewareVersion: Hashable {
    let version: String
}

struct BlockFields {
    let blockId: String
    let fields: [String: String]
}

extension BlockFields {
    func convertToMiddle() -> Anytype_Rpc.BlockList.Set.Fields.Request.BlockField {
        typealias ProtobufDictionary = [String: Google_Protobuf_Value]

        let protoFields = fields.reduce(ProtobufDictionary()) { dictionary, item in
            var dictionary = dictionary
            let protoValue = Google_Protobuf_Value(stringValue: item.value)
            dictionary[item.key] = protoValue
            return dictionary
        }
        let protobufStruct: Google_Protobuf_Struct = .init(fields: protoFields)

        return .init(blockID: blockId, fields: protobufStruct)
    }
}
