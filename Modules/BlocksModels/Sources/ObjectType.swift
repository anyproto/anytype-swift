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
    
    public let url: String
    public let name: String
    public let iconEmoji: Emoji
    public let description: String
    
    public let hidden: Bool
    public let readonly: Bool
    public let isArchived: Bool
    
    public let smartBlockTypes: Set<SmartBlockType>
    
    public init(
        url: String,
        name: String,
        iconEmoji: Emoji,
        description: String,
        hidden: Bool,
        readonly: Bool,
        isArchived: Bool,
        smartBlockTypes: Set<SmartBlockType>
    ) {
        self.url = url
        self.name = name
        self.iconEmoji = iconEmoji
        self.description = description
        self.hidden = hidden
        self.readonly = readonly
        self.isArchived = isArchived
        self.smartBlockTypes = smartBlockTypes
    }
}

extension ObjectType {
    
    init(model: Anytype_Model_ObjectType) {
        self.init(
            url: model.url,
            name: model.name,
            iconEmoji: Emoji(model.iconEmoji) ?? Emoji.default,
            description: model.description_p,
            hidden: model.hidden,
            readonly: model.readonly,
            isArchived: model.isArchived,
            smartBlockTypes: Set(model.types.compactMap { SmartBlockType(smartBlockType: $0) })
        )
    }
    
}
