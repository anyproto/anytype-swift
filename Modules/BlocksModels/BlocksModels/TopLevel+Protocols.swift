//
//  TopLevel+Protocols.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

public protocol TopLevelContainerModelHasRootIdProtocol {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    var rootId: BlockId? {get set}
}

public protocol TopLevelContainerModelProtocol: class, TopLevelContainerModelHasRootIdProtocol {
    var blocksContainer: BlockContainerModelProtocol {get set}
    var detailsContainer: DetailsContainerModelProtocol {get set}
}

public protocol TopLevelBuilder {
    static var blockBuilder: BlockBuilderProtocol {get}
    static var detailsBuilder: DetailsBuilderProtocol {get}
    static func emptyContainer() -> TopLevelContainerModelProtocol
    static func build(rootId: String?, blockContainer: BlockContainerModelProtocol, detailsContainer: DetailsContainerModelProtocol) -> TopLevelContainerModelProtocol
}

public protocol TopLevelAliasesMapProtocol {
    typealias BlockId = String
    typealias BlockContent = Block.Content.ContentType
    typealias ChildrenIds = [BlockId]
    typealias BackgroundColor = String
    typealias Alignment = Block.Information.Alignment
    typealias BlockKind = Block.Kind
    typealias Information = Block.Information
    typealias FocusPosition = Block.Focus.Position

    typealias DetailsInformation = Details.Information
    typealias DetailsId = String
    typealias DetailsContent = Details.Information.Content
}
