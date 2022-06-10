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
}

extension ObjectType {
    
    public static let fallbackType: ObjectType = ObjectType(
        url: ObjectTemplateType.bundled(.note).rawValue,
        name: "Note".localized,
        iconEmoji: .default,
        description: "Blank canvas with no title".localized,
        hidden: false,
        readonly: false,
        isArchived: false,
        smartBlockTypes: [.page]
    )
    
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
