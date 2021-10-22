//
//  ObjectDetails.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 06.10.2021.
//  Copyright © 2021 Dmitry Lobanov. All rights reserved.
//

import Foundation
import AnytypeCore
import SwiftProtobuf

public struct ObjectDetails: Hashable {
    
    public let id: String
    public let values: [String: Google_Protobuf_Value]
    
    public init(id: String, values: [String: Google_Protobuf_Value]) {
        self.id = id
        self.values = values
    }
    
    public func updated(by rawDetails: [String: Google_Protobuf_Value]) -> ObjectDetails {
        guard !rawDetails.isEmpty else { return self }
        
        let newValues = self.values.merging(rawDetails) { (_, new) in new }
        
        return ObjectDetails(
            id: self.id,
            values: newValues
        )
    }
    
    public func removed(keys: [String]) -> ObjectDetails {
        guard keys.isNotEmpty else { return self }
        
        var currentValues = self.values
        
        keys.forEach {
            currentValues.removeValue(forKey: $0)
        }
        
        return ObjectDetails(
            id: self.id,
            values: currentValues
        )
    }
    
}

public extension ObjectDetails {
    
    var name: String {
        stringValue(with: .name)
    }
    
    var iconEmoji: String {
        stringValue(with: .iconEmoji)
    }
    
    var iconImageHash: Hash? {
        guard let value = values[RelationKey.iconImage.rawValue] else { return nil }
        return Hash(value.unwrapedListValue.stringValue)
    }
    
    var coverId: String {
        stringValue(with: .coverId)
    }
    
    var coverType: CoverType {
        guard
            let value = values[RelationKey.coverType.rawValue],
            let number = value.unwrapedListValue.safeIntValue,
            let coverType = CoverType(rawValue: number)
        else { return .none }
        
        return coverType
    }
    
    var isArchived: Bool {
        boolValue(with: .isArchived)
    }
    
    var isFavorite: Bool {
        boolValue(with: .isFavorite)
    }
    
    var description: String {
        stringValue(with: .description)
    }
    
    var layout: DetailsLayout {
        guard
            let value = values[RelationKey.layout.rawValue],
            let number = value.unwrapedListValue.safeIntValue,
            let layout = DetailsLayout(rawValue: number)
        else {
            return .basic
        }
        return layout
    }
    
    var layoutAlign: LayoutAlignment {
        guard
            let value = values[RelationKey.layoutAlign.rawValue],
            let number = value.unwrapedListValue.safeIntValue,
            let layout = LayoutAlignment(rawValue: number)
        else {
            return .left
        }
        return layout
    }
    
    var isDone: Bool {
        boolValue(with: .done)
    }
    
    var type: String {
        stringValue(with: .type)
    }
    
    var isDraft: Bool {
        boolValue(with: .isDraft)
    }
    
    var featuredRelations: Set<String> {
        guard let value = values[RelationKey.featuredRelations.rawValue] else { return [] }
        
        let ids: [String] = value.listValue.values.compactMap {
            let value = $0.stringValue
            guard value.isNotEmpty else { return nil }
            return value
        }
        
        return Set(ids)
    }
    
    
    private func stringValue(with key: RelationKey) -> String {
        guard let value = values[key.rawValue] else { return "" }
        return value.unwrapedListValue.stringValue
    }
    
    private func boolValue(with key: RelationKey) -> Bool {
        guard let value = values[key.rawValue] else { return false }
        return value.unwrapedListValue.boolValue
    }
}

public struct ObjectDetails2: Hashable {
    public let id: String

    public private(set) var name: String = ObjectDetailDefaultValue.string
    public private(set) var iconEmoji: String = ObjectDetailDefaultValue.string
    public private(set) var iconImageHash: Hash? = ObjectDetailDefaultValue.hash
    public private(set) var coverId: String = ObjectDetailDefaultValue.string
    public private(set) var coverType: CoverType = ObjectDetailDefaultValue.coverType
    public private(set) var isArchived: Bool = ObjectDetailDefaultValue.bool
    public private(set) var isFavorite: Bool = ObjectDetailDefaultValue.bool
    public private(set) var description: String = ObjectDetailDefaultValue.string
    public private(set) var layout: DetailsLayout = ObjectDetailDefaultValue.layout
    public private(set) var layoutAlign: LayoutAlignment = ObjectDetailDefaultValue.layoutAlignment
    public private(set) var isDone: Bool = ObjectDetailDefaultValue.bool
    public private(set) var type: String = ObjectDetailDefaultValue.string
    public private(set) var isDraft: Bool = ObjectDetailDefaultValue.bool
    public private(set) var featuredRelations: [String] = ObjectDetailDefaultValue.featuredRelations
    
    public init(id: String, rawDetails: ObjectRawDetails) {
        self.id = id
        rawDetails.forEach {
            switch $0 {
            case .name(let value): name = value
            case .iconEmoji(let value): iconEmoji = value
            case .iconImageHash(let value): iconImageHash = value
            case .coverId(let value): coverId = value
            case .coverType(let value): coverType = value
            case .isArchived(let value): isArchived = value
            case .isFavorite(let value): isFavorite = value
            case .description(let value): description = value
            case .layout(let value): layout = value
            case .layoutAlign(let value): layoutAlign = value
            case .isDone(let value): isDone = value
            case .type(let value): type = value
            case .isDraft(let value): isDraft = value
            case .featuredRelations(ids: let value): featuredRelations = value
            }
        }
    }
    
    public func updated(by rawDetails: ObjectRawDetails) -> ObjectDetails2 {
        guard rawDetails.isNotEmpty else { return self }
        
        var currentDetails = self
        
        rawDetails.forEach {
            switch $0 {
            case .name(let value): currentDetails.name = value
            case .iconEmoji(let value): currentDetails.iconEmoji = value
            case .iconImageHash(let value): currentDetails.iconImageHash = value
            case .coverId(let value): currentDetails.coverId = value
            case .coverType(let value): currentDetails.coverType = value
            case .isArchived(let value): currentDetails.isArchived = value
            case .isFavorite(let value): currentDetails.isFavorite = value
            case .description(let value): currentDetails.description = value
            case .layout(let value): currentDetails.layout = value
            case .layoutAlign(let value): currentDetails.layoutAlign = value
            case .isDone(let value): currentDetails.isDone = value
            case .type(let value): currentDetails.type = value
            case .isDraft(let value): currentDetails.isDraft = value
            case .featuredRelations(ids: let value): currentDetails.featuredRelations = value
            }
        }
        
        return currentDetails
    }
    
}
