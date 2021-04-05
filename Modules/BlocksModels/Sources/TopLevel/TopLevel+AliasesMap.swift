//
//  TopLevel+AliasesMap.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

public extension TopLevel {
    typealias BlockId = String
    typealias BlockContent = Block.Content.ContentType
    typealias ChildrenIds = [BlockId]
    typealias BackgroundColor = String
    typealias Alignment = Block.Information.Alignment
    typealias Position = Block.Common.Position
    
    typealias BlockKind = Block.Common.Kind
    typealias FocusPosition = Block.Common.Focus.Position

    typealias DetailsId = String
    typealias DetailsContent = Details.Information.Content
    
    typealias BlockTools = Block.Tools
    typealias BlockUtilities = Block.Utilities
    
    //TODO: Remove when possible.
    /// Deprecated.
    /// We shouldn't convert details to blocks...
    typealias InformationUtilitiesDetailsBlockConverter = Block.Information.DetailsAsBlockConverter
}
