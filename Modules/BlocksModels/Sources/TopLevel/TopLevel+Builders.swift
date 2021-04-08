//
//  TopLevel+Builders.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

public extension TopLevel {
    enum Builder: TopLevelBuilder {
        public static var blockBuilder: BlockBuilderProtocol = Block.Builder.init()
        public static var detailsBuilder: DetailsBuilderProtocol = Details.Builder.init()
        
        public static func emptyContainer() -> TopLevelContainerModelProtocol {
            RootBlocksContainer()
        }
        
        public static func createRootContainer(rootId: BlockId?,
                                 blockContainer: BlockContainerModelProtocol,
                                 detailsContainer: DetailsContainerModelProtocol) -> TopLevelContainerModelProtocol {
            let container = RootBlocksContainer()
            container.rootId = rootId
            container.blocksContainer = blockContainer
            container.detailsContainer = detailsContainer
            return container
        }
    }
}
