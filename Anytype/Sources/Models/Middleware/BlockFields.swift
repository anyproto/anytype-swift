import ProtobufMessages
import SwiftProtobuf

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
