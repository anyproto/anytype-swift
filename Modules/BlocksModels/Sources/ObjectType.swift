//
//  ObjectType.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 10.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import ProtobufMessages
import AnytypeCore

public struct ObjectType: Equatable, Hashable, Codable {
    
    public let id: String
    public let name: String
    public let iconEmoji: Emoji
    public let description: String
    
    public let hidden: Bool
    public let readonly: Bool
    public let isArchived: Bool
    public let sourceObject: String
    
    public let smartBlockTypes: Set<SmartBlockType>
    
    public init(
        id: String,
        name: String,
        iconEmoji: Emoji,
        description: String,
        hidden: Bool,
        readonly: Bool,
        isArchived: Bool,
        sourceObject: String,
        smartBlockTypes: Set<SmartBlockType>
    ) {
        self.id = id
        self.name = name
        self.iconEmoji = iconEmoji
        self.description = description
        self.hidden = hidden
        self.readonly = readonly
        self.isArchived = isArchived
        self.sourceObject = sourceObject
        self.smartBlockTypes = smartBlockTypes
    }
}

extension ObjectType {
    
    public init(details: ObjectDetails) {
        self.init(
            id: details.id,
            name: details.name,
            iconEmoji: details.iconEmoji ?? Emoji.default,
            description: details.description,
            hidden: details.isHidden,
            readonly: details.isReadonly,
            isArchived: details.isArchived,
            sourceObject: details.sourceObject,
            smartBlockTypes: Set(details.smartblockTypesValue)
        )
    }
    
}
