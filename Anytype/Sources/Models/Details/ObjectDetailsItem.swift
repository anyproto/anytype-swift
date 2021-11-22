//
//  ObjectDetailsItem.swift
//  Anytype
//
//  Created by Konstantin Mordan on 22.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import AnytypeCore
import BlocksModels
import ProtobufMessages
import SwiftProtobuf

enum ObjectDetailsItem {
    case name(String)
    case iconEmoji(String)
    case iconImageHash(Hash?)
    case coverId(String)
    case coverType(CoverType)
    case type(ObjectTemplateType)
    case isDraft(Bool)
}

typealias ObjectRawDetails = [ObjectDetailsItem]

extension ObjectRawDetails {
    
    public var asMiddleware: [Anytype_Rpc.Block.Set.Details.Detail] {
        self.compactMap {
            switch $0 {
            case .name(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: BundledRelationKey.name.rawValue,
                    value: string.protobufValue
                )
                
            case .iconEmoji(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: BundledRelationKey.iconEmoji.rawValue,
                    value: string.protobufValue
                )
                
            case .iconImageHash(let hash):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: BundledRelationKey.iconImage.rawValue,
                    value: (hash?.value ?? "").protobufValue
                )
                
            case .coverId(let coverId):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: BundledRelationKey.coverId.rawValue,
                    value: coverId.protobufValue
                )
                
            case .coverType(let coverType):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: BundledRelationKey.coverType.rawValue,
                    value: coverType.rawValue.protobufValue
                )
            case .type(let type):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: BundledRelationKey.type.rawValue,
                    value: type.rawValue.protobufValue
                )
            case .isDraft(let isDraft):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: BundledRelationKey.isDraft.rawValue,
                    value: isDraft.protobufValue
                )
            }
        }
    }
    
}

