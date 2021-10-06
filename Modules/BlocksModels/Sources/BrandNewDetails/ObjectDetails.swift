//
//  ObjectDetails.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 06.10.2021.
//  Copyright © 2021 Dmitry Lobanov. All rights reserved.
//

import Foundation
import AnytypeCore

public struct ObjectDetails {
    public private(set) var name: String? = nil
    public private(set) var iconEmoji: String? = nil
    public private(set) var iconImageHash: Hash? = nil
    public private(set) var coverId: String? = nil
    public private(set) var coverType: CoverType? = nil
    public private(set) var isArchived: Bool = false
    public private(set) var isFavorite: Bool = false
    public private(set) var description: String? = nil
    public private(set) var layout: DetailsLayout = .basic
    public private(set) var layoutAlign: LayoutAlignment = .left
    public private(set) var isDone: Bool = false
    public private(set) var type: String? = nil
    
    public init(_ rawDetails: ObjectRawDetails) {
        rawDetails.forEach {
            switch $0 {
            case .name(let value):
                name = value
            case .iconEmoji(let value):
                iconEmoji = value
            case .iconImageHash(let value):
                iconImageHash = value
            case .coverId(let value):
                coverId = value
            case .coverType(let value):
                coverType = value
            case .isArchived(let value):
                isArchived = value
            case .isFavorite(let value):
                isFavorite = value
            case .description(let value):
                description = value
            case .layout(let value):
                layout = value
            case .layoutAlign(let value):
                layoutAlign = value
            case .isDone(let value):
                isDone = value
            case .type(let value):
                type = value
            }
        }
    }
    
}
