//
//  ObjectDetailsItem.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 06.10.2021.
//  Copyright © 2021 Dmitry Lobanov. All rights reserved.
//

import Foundation
import AnytypeCore

public enum ObjectDetailsItem {
    case name(String)
    case iconEmoji(String)
    case iconImageHash(Hash?)
    case coverId(String)
    case coverType(CoverType)
    case isArchived(Bool)
    case isFavorite(Bool)
    case description(String)
    case layout(DetailsLayout)
    case layoutAlign(LayoutAlignment)
    case isDone(Bool)
    case type(String)
    case isDraft(Bool)
}
