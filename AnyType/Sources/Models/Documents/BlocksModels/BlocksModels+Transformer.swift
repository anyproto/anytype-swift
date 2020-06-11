//
//  BlocksModels+Transformer.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 04.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let blocksModelsTransformer: Self = "BlocksModels.Transformer"
}

extension BlocksModels {
    class Transformer {
        typealias Model = BlocksModelsBlockModelProtocol
        typealias HighModel = BlocksModelsChosenBlockModelProtocol
        typealias Information = BlocksModelsInformationModelProtocol
        typealias BlockId = BlocksModels.Aliases.BlockId
        typealias Container = BlocksModelsContainerModelProtocol
        typealias Builder = BlocksModels.Block.Builder
    }
}

// MARK: From list to tree
extension BlocksModels.Transformer {
    fileprivate struct FromListToTreeTransformer {
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
        private func fromList(information: [Information], isRoot: (Model) -> Bool) -> Container {
            fromList(information.compactMap({Builder.build(information: $0)}), isRoot: isRoot)
        }
        
        private func fromList(_ models: [Model], isRoot: (Model) -> Bool) -> Container {
            
            // 1. create dictionary: ID -> Model
            var container = Builder.build(list: models)
            
            // 2. check if we have only one root
            let roots = models.filter(isRoot)

            guard roots.count != 0 else {
                let logger = Logging.createLogger(category: .blocksModelsTransformer)
                os_log(.error, log: logger, "Unknown situation. We can't have zero roots.")
                return Builder.emptyContainer()
            }
            
            // 3. If we have several roots, so, notify about it.
            if roots.count != 1 {
                // this situation is not possible, but, let handle it.
                let logger = Logging.createLogger(category: .blocksModelsTransformer)
                os_log(.debug, log: logger, "We have several roots for our rootId. Not possible, but let us handle it.")
            }
            
            // 4. find root id as first element in roots. No matter, how much roots we have.
            let rootId = roots[0].information.id
            container.rootId = rootId
            
            // 5. Build tree.
            Builder.buildTree(container: container)
            
            return container
        }
                
        // MARK: Target rootId.
        func fromList(information: [Information], rootId: BlockId) -> Container {
            fromList(information: information, isRoot: { $0.information.id == rootId })
        }
    }
}

//// MARK: ToList
extension BlocksModels.Transformer {
    struct FromTreeToListTransformer {
        private func toListRecursively(_ block: HighModel) -> [HighModel] {
            var result: [HighModel] = []
            result.append(contentsOf: block.childrenIds().map({block.findChild(by: $0)}).compactMap({$0}))
            return result
        }
        public func toList(_ model: HighModel) -> [HighModel] {
            self.toListRecursively(model)
        }
    }
}

extension BlocksModels.Transformer {
    struct FinalTransformer {
        private var fromListToTree = FromListToTreeTransformer()
        public func transform(_ information: [Information], rootId: BlockId) -> Container {
            fromListToTree.fromList(information: information, rootId: rootId)
        }
    }
}
