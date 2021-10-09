//
//  ObjectRawDetailsConverter.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 06.10.2021.
//  Copyright © 2021 Dmitry Lobanov. All rights reserved.
//

import Foundation
import SwiftProtobuf
import AnytypeCore
import ProtobufMessages

public enum ObjectRawDetailsConverter {
    
    public static func convertMiddlewareDetails(_ details: [String: Google_Protobuf_Value]) -> ObjectRawDetails {
        details.compactMap { key, value -> ObjectDetailsItem? in
            guard let itemKey = ObjectDetailsItemKey(rawValue: key) else {
                return nil
            }
            
            let unwrapedListValue = value.unwrapedListValue
            
            switch itemKey {
            case .name:
                return ObjectDetailsItem.name(unwrapedListValue.stringValue)
                
            case .iconEmoji:
                return .iconEmoji(unwrapedListValue.stringValue)
                
            case .iconImageHash:
                guard let hash = Hash(unwrapedListValue.stringValue) else { return nil }
                return .iconImageHash(hash)
                
            case .coverId:
                return .coverId(unwrapedListValue.stringValue)
                
            case .coverType:
                guard
                    let number = unwrapedListValue.safeIntValue,
                    let coverType = CoverType(rawValue: number)
                else {
                    return nil
                }
                
                return .coverType(coverType)
                
            case .isArchived:
                return .isArchived(unwrapedListValue.boolValue)
                
            case .isFavorite:
                return .isFavorite(unwrapedListValue.boolValue)
                
            case .description:
                return .description(unwrapedListValue.stringValue)
                
            case .layout:
                guard
                    let number = unwrapedListValue.safeIntValue,
                    let layout = DetailsLayout(rawValue: number)
                else {
                    return nil
                }
                return .layout(layout)
                
            case .layoutAlign:
                guard
                    let number = unwrapedListValue.safeIntValue,
                    let layout = LayoutAlignment(rawValue: number)
                else {
                    return nil
                }
                return .layoutAlign(layout)
                
            case .isDone:
                return .isDone(unwrapedListValue.boolValue)
                
            case .type:
                return .type(unwrapedListValue.stringValue)
            }
        }
    }
    
    public static func convertObjectRawDetails(_ details: ObjectRawDetails) -> [Anytype_Rpc.Block.Set.Details.Detail] {
        details.map {
            switch $0 {
            case .name(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.name.rawValue,
                    value: Google_Protobuf_Value(stringValue: string)
                )
                
            case .iconEmoji(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.iconEmoji.rawValue,
                    value: Google_Protobuf_Value(stringValue: string)
                )
                
            case .iconImageHash(let hash):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.iconImageHash.rawValue,
                    value: Google_Protobuf_Value(stringValue: hash?.value ?? "")
                )
                
            case .coverId(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.coverId.rawValue,
                    value: Google_Protobuf_Value(stringValue: string)
                )
                
            case .coverType(let coverType):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.coverType.rawValue,
                    value: Google_Protobuf_Value(numberValue: Double(coverType.rawValue))
                )
                
            case .isArchived(let bool):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.isArchived.rawValue,
                    value: Google_Protobuf_Value(boolValue: bool)
                )
                
            case .isFavorite(let bool):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.isFavorite.rawValue,
                    value: Google_Protobuf_Value(boolValue: bool)
                )
                
            case .description(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.description.rawValue,
                    value: Google_Protobuf_Value(stringValue: string)
                )
                
            case .layout(let layout):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.layout.rawValue,
                    value: Google_Protobuf_Value(numberValue: Double(layout.rawValue))
                )
                
            case .layoutAlign(let layoutAlign):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.layoutAlign.rawValue,
                    value: Google_Protobuf_Value(numberValue: Double(layoutAlign.rawValue))
                )
                
            case .isDone(let bool):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.isDone.rawValue,
                    value: Google_Protobuf_Value(boolValue: bool)
                )
                
            case .type(let string):
                return Anytype_Rpc.Block.Set.Details.Detail(
                    key: ObjectDetailsItemKey.type.rawValue,
                    value: Google_Protobuf_Value(stringValue: string)
                )
            }
        }
    }
    
}

