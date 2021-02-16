//
//  TopLevel+Builders.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = TopLevel

public extension Namespace {
    enum Builder: TopLevelBuilder {
        typealias Model = Container
        public typealias BlockId = TopLevel.AliasesMap.BlockId
        public static var blockBuilder: BlockBuilderProtocol = Block.Builder.init()
        public static var detailsBuilder: DetailsBuilderProtocol = Details.Builder.init()
        
        public static func emptyContainer() -> TopLevelContainerModelProtocol {
            Model.init()
        }
        
        public static func build(rootId: BlockId?, blockContainer: BlockContainerModelProtocol, detailsContainer: DetailsContainerModelProtocol) -> TopLevelContainerModelProtocol {
            let model = Model.init()
            model.rootId = rootId
            model.blocksContainer = blockContainer
            model.detailsContainer = detailsContainer
            return model
        }

    }
}
