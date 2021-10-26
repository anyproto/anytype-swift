import ProtobufMessages
import SwiftProtobuf
import AnytypeCore

public typealias ObjectRawDetails = [ObjectDetailsItem]

extension ObjectRawDetails {
    
    public var asMiddleware: [Anytype_Rpc.Block.Set.Details.Detail] {
        self.compactMap {
            switch $0 {
            case .name(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationKey.name.rawValue,
                    value: Google_Protobuf_Value(stringValue: string)
                )
                
            case .iconEmoji(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationKey.iconEmoji.rawValue,
                    value: Google_Protobuf_Value(stringValue: string)
                )
                
            case .iconImageHash(let hash):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationKey.iconImage.rawValue,
                    value: Google_Protobuf_Value(stringValue: hash?.value ?? "")
                )
                
            case .coverId(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationKey.coverId.rawValue,
                    value: Google_Protobuf_Value(stringValue: string)
                )
                
            case .coverType(let coverType):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationKey.coverType.rawValue,
                    value: Google_Protobuf_Value(numberValue: Double(coverType.rawValue))
                )
            case .type(let type):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationKey.type.rawValue,
                    value: Google_Protobuf_Value(stringValue: type.rawValue)
                )
            case .isDraft(let bool):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationKey.isDraft.rawValue,
                    value: Google_Protobuf_Value(boolValue: bool)
                )
            }
        }
    }
    
}
