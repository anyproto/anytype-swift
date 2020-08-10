//
//  TopLevel+AliasesMap.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = TopLevel

public extension Namespace {
    enum AliasesMap {} //: TopLevelAliasesMapProtocol {}
}

public extension Namespace.AliasesMap {
    typealias BlockId = String
    typealias BlockContent = Block.Content.ContentType
    typealias ChildrenIds = [BlockId]
    typealias BackgroundColor = String
    typealias Alignment = Block.Information.Alignment
    
    typealias BlockKind = Block.Kind
    typealias FocusPosition = Block.Focus.Position

    typealias DetailsId = String
    typealias DetailsContent = Details.Information.Content
    
    typealias BlockTools = Block.Tools
    typealias BlockUtilities = Block.Utilities
    typealias DetailsUtilities = Details.Utilities
    
    //TODO: Remove when possible.
    /// Deprecated.
    /// We shouldn't convert details to blocks...
    typealias InformationUtilitiesDetailsBlockConverter = Block.Information.DetailsAsBlockConverter
}
