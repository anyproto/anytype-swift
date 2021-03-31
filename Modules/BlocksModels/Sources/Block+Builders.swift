//
//  Block+Builders.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let blocksModelsBlockBuilder: Self = "BlocksModels.Block.Builder"
}

public protocol BlockBuilderProtocol {
    func build(list: [BlockModelProtocol]) -> BlockContainerModelProtocol
    func buildTree(container: BlockContainerModelProtocol, rootId: String?)
    func emptyContainer() -> BlockContainerModelProtocol
    func build(information: Block.Information.InformationModel) -> BlockModelProtocol
    var informationBuilder: BlockInformationBuilderProtocol {get}
}

extension Block {
    class Builder: BlockBuilderProtocol {
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias Model = BlockModel
        typealias CurrentContainer = Container
        typealias InformationBuilder = Information.Builder
        
        func build(list: [BlockModelProtocol]) -> BlockContainerModelProtocol {
            let container: CurrentContainer = .init()
            list.forEach(container.add(_:))
            return container
        }
        
        func emptyContainer() -> BlockContainerModelProtocol {
            build(list: [])
        }
        
        private func buildTreeRecursively(container: BlockContainerModelProtocol, id: BlockId) {
            if let entry = container.choose(by: id) {
                let parentId = id
                entry.childrenIds().forEach { (value) in
                    var blockModel = entry.findChild(by: value)?.blockModel
                    blockModel?.parent = parentId
                    self.buildTreeRecursively(container: container, id: value)
                }
            }
        }
        
        func buildTree(container: BlockContainerModelProtocol, rootId: String?) {
            if let rootId = rootId {
                self.buildTreeRecursively(container: container, id: rootId)
            }
            else {
                let logger = Logging.createLogger(category: .blocksModelsBlockBuilder)
                os_log(.debug, log: logger, "Can't build tree. RootId is nil")
            }
        }
        
        func build(information: Block.Information.InformationModel) -> BlockModelProtocol {
            Model.init(information: information)
        }
        
        // MARK: Information
        var informationBuilder: BlockInformationBuilderProtocol = InformationBuilder.init()
    }
}
