//
//  AnytypeDetailsConverter.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 10.10.2021.
//  Copyright © 2021 Dmitry Lobanov. All rights reserved.
//

import Foundation
import SwiftProtobuf
import AnytypeCore
import ProtobufMessages

public enum MiddlewareDetailsConverter {
    
    public static func convertSetEvent(_ event: Anytype_Event.Object.Details.Set) -> ObjectRawDetails {
        convertMiddlewareDetailsDictionary(
            event.details.fields
        )
    }
    
    public static func convertAmendEvent(_ event: Anytype_Event.Object.Details.Amend) -> ObjectRawDetails {
        convertMiddlewareDetailsDictionary(
            event.details.asDetailsDictionary
        )
    }
    
    public static func convertUnsetEvent(_ event: Anytype_Event.Object.Details.Unset) -> ObjectRawDetails {
        event.keys.compactMap {
            guard let key = ObjectDetailsItemKey(rawValue: $0) else {
                return nil
            }
            
            return ObjectDetailsItem.defaultValueItem(by: key)
        }
    }
    
    public static func convertMiddlewareDetailsDictionary(_ details: [String: Google_Protobuf_Value]) -> ObjectRawDetails {
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
            case .lastOpenedDate:
                return nil
            case .isHidden:
                return nil
            case .lastModifiedDate:
                return nil
            case .isDraft:
                return .isDraft(unwrapedListValue.boolValue)
            }
        }
    }
 
}

private extension Array where Element == Anytype_Event.Object.Details.Amend.KeyValue {

    var asDetailsDictionary: [String: Google_Protobuf_Value] {
        reduce(
            into: [String: Google_Protobuf_Value]()
        ) { result, detail in
            result[detail.key] = detail.value
        }
    }
    
}

private extension ObjectDetailsItem {
    
    static func defaultValueItem(by key: ObjectDetailsItemKey) -> ObjectDetailsItem? {
        switch key {
        case .name: return .name(ObjectDetailDefaultValue.string)
        case .iconEmoji: return .iconEmoji(ObjectDetailDefaultValue.string)
        case .iconImageHash: return .iconImageHash(ObjectDetailDefaultValue.hash)
        case .coverId: return .coverId(ObjectDetailDefaultValue.string)
        case .coverType: return .coverType(ObjectDetailDefaultValue.coverType)
        case .isArchived: return .isArchived(ObjectDetailDefaultValue.bool)
        case .isFavorite: return .isFavorite(ObjectDetailDefaultValue.bool)
        case .description: return .description(ObjectDetailDefaultValue.string)
        case .layout: return .layout(ObjectDetailDefaultValue.layout)
        case .layoutAlign: return .layoutAlign(ObjectDetailDefaultValue.layoutAlignment)
        case .isDone: return .isDone(ObjectDetailDefaultValue.bool)
        case .type: return .type(ObjectDetailDefaultValue.string)
        case .isDraft: return .isDraft(ObjectDetailDefaultValue.bool)
        case .lastOpenedDate: return nil
        case .isHidden: return nil
        case .lastModifiedDate: return nil
        }
    }
    
}
