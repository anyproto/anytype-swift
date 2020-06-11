//
//  BlocksModels+Block+Builders.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 04.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let blocksModelsBlockBuilder: Self = "BlocksModels.Block.Builder"
}

protocol BlocksModelsBuilderProtocol {
    static func build(list: [BlocksModelsBlockModelProtocol]) -> BlocksModelsContainerModelProtocol
    static func buildTree(container: BlocksModelsContainerModelProtocol)
    static func emptyContainer() -> BlocksModelsContainerModelProtocol
    static func build(information: BlocksModelsInformationModelProtocol) -> BlocksModelsBlockModelProtocol
}

extension BlocksModels.Block {
    class Builder: BlocksModelsBuilderProtocol {
        typealias BlockId = BlocksModels.Aliases.BlockId
        typealias Model = BlocksModels.Block.BlockModel
        
        class func build(list: [BlocksModelsBlockModelProtocol]) -> BlocksModelsContainerModelProtocol {
            let container: BlocksModels.Block.Container = .init()
            list.forEach(container.add(_:))
            return container
        }
        
        class func emptyContainer() -> BlocksModelsContainerModelProtocol {
            build(list: [])
        }
        
        private class func buildTreeRecursively(container: BlocksModelsContainerModelProtocol, id: BlockId) {
            if let entry = container.choose(by: id) {
                entry.childrenIds().forEach { (value) in
                    var blockModel = entry.findChild(by: value)?.blockModel
                    blockModel?.parent = id
                    self.buildTreeRecursively(container: container, id: value)
                }
            }
        }
        
        class func buildTree(container: BlocksModelsContainerModelProtocol) {
            if let rootId = container.rootId {
                self.buildTreeRecursively(container: container, id: rootId)
            }
            else {
                let logger = Logging.createLogger(category: .blocksModelsBlockBuilder)
                os_log(.debug, log: logger, "Can't build tree. RootId is nil")
            }
        }
        
        class func build(information: BlocksModelsInformationModelProtocol) -> BlocksModelsBlockModelProtocol {
            Model.init(information: information)
        }
    }
}
