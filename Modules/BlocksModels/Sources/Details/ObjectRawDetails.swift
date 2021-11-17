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
                    key: RelationMetadataKey.name.rawValue,
                    value: string.protobufValue
                )
                
            case .iconEmoji(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationMetadataKey.iconEmoji.rawValue,
                    value: string.protobufValue
                )
                
            case .iconImageHash(let hash):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationMetadataKey.iconImage.rawValue,
                    value: (hash?.value ?? "").protobufValue
                )
                
            case .coverId(let coverId):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationMetadataKey.coverId.rawValue,
                    value: coverId.protobufValue
                )
                
            case .coverType(let coverType):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationMetadataKey.coverType.rawValue,
                    value: coverType.rawValue.protobufValue
                )
            case .type(let type):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationMetadataKey.type.rawValue,
                    value: type.rawValue.protobufValue
                )
            case .isDraft(let isDraft):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: RelationMetadataKey.isDraft.rawValue,
                    value: isDraft.protobufValue
                )
            }
        }
    }
    
}
