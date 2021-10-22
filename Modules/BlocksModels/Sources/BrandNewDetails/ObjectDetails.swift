//
//  ObjectDetails.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 06.10.2021.
//  Copyright © 2021 Dmitry Lobanov. All rights reserved.
//

import Foundation
import AnytypeCore

public struct ObjectDetails: Hashable {
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
            case .type(let value): type = value.rawValue
            case .isDraft(let value): isDraft = value
            case .featuredRelations(ids: let value): featuredRelations = value
            }
        }
    }
    
    public func updated(by rawDetails: ObjectRawDetails) -> ObjectDetails {
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
            case .type(let value): currentDetails.type = value.rawValue
            case .isDraft(let value): currentDetails.isDraft = value
            case .featuredRelations(ids: let value): currentDetails.featuredRelations = value
            }
        }
        
        return currentDetails
    }
    
}
