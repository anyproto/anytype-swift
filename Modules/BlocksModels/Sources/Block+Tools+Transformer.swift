//
//  Block+Tools+Transformer.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let blocksModelsToolsTransformer: Self = "BlocksModels.Tools.Transformer"
}

fileprivate typealias Namespace = Block.Tools

public extension Namespace {
    enum Transformer {
        public typealias Model = BlockModelProtocol
        public typealias ActiveRecord = BlockActiveRecordModelProtocol
        public typealias BlockId = TopLevel.AliasesMap.BlockId
        public typealias Container = BlockContainerModelProtocol
        
        /// Internal only. Implementation.
        typealias Builder = TopLevel.Builder
    }
}

// MARK: From list to tree
fileprivate extension Namespace.Transformer {
    struct FromListToTreeTransformer {
        private var builder: BlockBuilderProtocol
        /// Description
        ///
        /// Steps
        /// 1. create dictionary: ID -> Model
        /// 2. check if we have only one root
        /// 3. If we have several roots, so, notify about it.
        /// 4. find root id as first element in roots. No matter, how much roots we have.
        /// 5. Build tree.
        /// Note
        ///
        /// 6 is necessary
        ///
        /// Observation
        ///
        /// Consider unsorted (not sorted topologically) blocks.
        /// At the end we _may_ don't know if these blocks have correct indices or not.
        /// For that case we _should_ rerun building indices in second time after we determine root.
        private func fromList(information: [Block.Information.InformationModel], isRoot: (Model) -> Bool) -> Container {
            fromList(information.compactMap({self.builder.build(information: $0)}), isRoot: isRoot)
        }
        
        private func fromList(_ models: [Model], isRoot: (Model) -> Bool) -> Container {
            
            // 1. create dictionary: ID -> Model
            var container = self.builder.build(list: models)
            
            // 2. check if we have only one root
            let roots = models.filter(isRoot)

            guard roots.count != 0 else {
                let logger = Logging.createLogger(category: .blocksModelsToolsTransformer)
                os_log(.error, log: logger, "Unknown situation. We can't have zero roots.")
                return self.builder.emptyContainer()
            }
            
            // 3. If we have several roots, so, notify about it.
            if roots.count != 1 {
                // this situation is not possible, but, let handle it.
                let logger = Logging.createLogger(category: .blocksModelsToolsTransformer)
                os_log(.debug, log: logger, "We have several roots for our rootId. Not possible, but let us handle it.")
            }
            
            // 4. find root id as first element in roots. No matter, how much roots we have.
            // But for now we don't need root id in this container.
            let rootId = roots[0].information.id
            container.rootId = rootId
            
            // 5. Build tree.
            self.builder.buildTree(container: container, rootId: rootId)
            
            return container
        }
                
        // MARK: Target rootId.
        func fromList(information: [Block.Information.InformationModel], rootId: BlockId) -> Container {
            fromList(information: information, isRoot: { $0.information.id == rootId })
        }
        
        init(builder: BlockBuilderProtocol) {
            self.builder = builder
        }
    }
}

//// MARK: ToList
extension Namespace.Transformer {
    struct FromTreeToListTransformer {
        private func toListRecursively(_ block: ActiveRecord) -> [ActiveRecord] {
            var result: [ActiveRecord] = []
            result.append(contentsOf: block.childrenIds().map(block.findChild(by:)).compactMap({$0}))
            return result
        }
        public func toList(_ model: ActiveRecord) -> [ActiveRecord] {
            self.toListRecursively(model)
        }
    }
}

public extension Namespace.Transformer {
    struct FinalTransformer {
        private var fromListToTree: FromListToTreeTransformer
        public func transform(_ information: [Block.Information.InformationModel], rootId: BlockId) -> Container {
            fromListToTree.fromList(information: information, rootId: rootId)
        }
        public init(builder: BlockBuilderProtocol) {
            self.fromListToTree = .init(builder: builder)
        }
        public static var defaultValue: Self = {
            Self.init(builder: Builder.blockBuilder)
        }()
    }
}
