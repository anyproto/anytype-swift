//
//  BlockModel+Transformer.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 23.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import os

private extension Logging.Categories {
    static let blockModelsTransformer: Self = "BlockModels.Transformer"
}

extension BlockModels {
    class Transformer {
        typealias Model = BlockModels.Block.RealBlock
        typealias Information = BlockModels.Block.Information
    }
}

// MARK: From list to tree
extension BlockModels.Transformer {
    fileprivate struct FromListToTreeTransformer {
        /// Description
        ///
        /// Steps
        /// 1. create dictionary: ID -> Model
        /// 2. move through all children and try to assign their children ids with corresponding blocks.
        /// 3. check if we have only one root
        /// 4. If we have one root, so, we don't need anything and just extract it.
        /// 5. If we have several roots, so, we should wrap them in one metablock.
        /// 6. Rebuild indices in case of new hierarchy. Do it from the root.
        /// 7. return model.
        ///
        /// Note
        ///
        /// 6 is necessary
        ///
        /// Observation
        ///
        /// Consider unsorted (not sorted topologically) blocks.
        /// At the end we _may_ don't know if these blocks have correct indices or not.
        /// For that case we _should_ rerun building indices in second time after we determine root.
        private func fromList(information: [Information], isRoot: (Model) -> Bool) -> Model {
            fromList(information.compactMap({Model.init(information: $0)}), isRoot: isRoot)
        }
        
        private func fromList(_ models: [Model], isRoot: (Model) -> Bool) -> Model {
            // 1. create dictionary: ID -> Model
            let dictionary = Dictionary<String, Model>.init(uniqueKeysWithValues: models.compactMap({($0.information.id, $0)}))
            
            // 2. move through all children and try to assign their children ids with corresponding blocks.
            for model in models {
                model.blocks = model.information.childrenIds.compactMap({dictionary[$0]})
            }
            
            // 3. check if we have only one root
            let roots = models.filter(isRoot)
            
            guard roots.count != 0 else {
                let logger = Logging.createLogger(category: .blockModelsTransformer)
                os_log(.error, log: logger, "Unknown situation. We can't have zero roots.")
                return Model.init(information: .defaultValue())
            }
            
            // 4. If we have one root, so, we don't need anything and just extract it.
            var rootModel = roots[0]
            rootModel.indexPath = BlockModels.Utilities.IndexGenerator.rootID()
            
            // 5. If we have several roots, so, we should wrap them in one metablock.
            if roots.count != 1 {
                // this situation is not possible, but, let handle it.
                let logger = Logging.createLogger(category: .blockModelsTransformer)
                os_log(.debug, log: logger, "We have several roots for our rootId. Not possible, but let us handle it.")
                rootModel = Model.init(indexPath: BlockModels.Utilities.IndexGenerator.rootID(), blocks: roots)
                rootModel.kind = .meta // default is .block
            }
            
            // 6. Rebuild indices in case of new hierarchy. Do it from the root.
            var queue: ArraySlice<Model> = [rootModel]
            while !queue.isEmpty {
                if let object = queue.first {
                    queue = queue.dropFirst()
                    object.buildIndexPaths()
                    queue.append(contentsOf: object.blocks.compactMap{$0 as? Model})
                }
            }

            // 7. return model.
            // Should we set rootModel as meta?
            // TODO: Discuss
            let logger = Logging.createLogger(category: .todo(.improve("")))
            os_log(.debug, log: logger, "Should we always return rootModel as meta?")
            return rootModel.with(kind: .meta)
        }
        
        // MARK: Manual determination of Root.
        func fromList(information: [Information]) -> Model {
            fromList(information: information, isRoot: {$0.isRoot})
        }
            
        func fromList(_ models: [Model]) -> Model {
            fromList(models, isRoot: {$0.isRoot})
        }
        
        // MARK: Target rootId.
        func fromList(information: [Information], rootId: MiddlewareBlockInformationModel.Id) -> Model {
            fromList(information: information, isRoot: { $0.information.id == rootId })
        }
        
        func fromList(_ models: [Model], rootId: MiddlewareBlockInformationModel.Id) -> Model {
            fromList(models, isRoot: {$0.information.id == rootId})
        }
    }
}

//// MARK: ToList
extension BlockModels.Transformer {
    struct FromTreeToListTransformer {
        // TODO: Remove complex hierarchy for BlockModel.Block.Node.RealBlock
        private func toListRecursively(_ block: Model) -> [Model] {
//            switch block.kind {
//            case .meta:
//                return block.blocks.compactMap({$0 as? Model}).flatMap(self.toListRecursively)
//            default:
            var result = [block]
            result.append(contentsOf: block.blocks.compactMap({$0 as? Model}).flatMap(self.toListRecursively))
            return result
//            }
        }
        func toList(_ model: Model) -> [Model] {
            self.toListRecursively(model)
        }
        func toList(_ models: [Model]) -> [Model] {
            // wrap in a metablock
            let root: Model = .init(indexPath: BlockModels.Utilities.IndexGenerator.rootID(), blocks: models)
            return toList(root)
        }
    }
}

// MARK: Apply numbered list transformer
extension BlockModels.Transformer {
    fileprivate struct ApplyNumberedListTransformer {
        // MARK: Match
        typealias Inspector = BlockModels.Utilities.Inspector
        private func matchBlocks(_ lhs: Model, _ rhs: Model) -> Bool {
            // if they are both numbered or numbered list OR they are not numbered.
            return ((Inspector.isNumberedList(lhs) || Inspector.isNumbered(lhs)) == (Inspector.isNumberedList(rhs) || Inspector.isNumbered(rhs)))
        }
        
        private func findSimilar(parent: Model) -> [[Model]] {
            return DataStructures.GroupBy.group(parent.blocks as! [Model], by: self.matchBlocks)
        }
        
        // MARK: EasyRelax
        private func transform(entry: Model, of cluster: [Model]) -> [Model] {
            if Inspector.isNumberedList(entry) || Inspector.isNumbered(entry) {
                
                // no need to process. if we met numbered list.
                //                if cluster.count == 1 && Inspector.isNumberedList(entry) {
                //                    return cluster
                //                }
                
                // find in list isNumberedList.
                // and replace its index ( not section ) by value of `entry.indexPath.item`.
                // If you don't find it, let create it with entry.indexPath
                // We also do not include this block, because it will include itself.
                
                //                let block = cluster.first(where: Inspector.isNumberedList).flatMap{
                //                    $0.indexPath.item = entry.indexPath.item
                //                    return $0
                //                } ??
                let block = Model.init(indexPath: entry.indexPath, blocks: []).with(kind: .meta)
                
                // We should remove MetaBlock here.
                
                let result = cluster.reduce(block) { (result, value) in
                    if Inspector.isNumbered(value) {
                        result.blocks.append(value)
                    }
                    else if Inspector.isNumberedList(value) {
                        result.blocks.append(contentsOf: value.blocks)
                    }
                    return result
                }
                result.buildIndexPaths()
                return [result]
            }
            return cluster
        }
        
        private func transform(models: [Model]) -> [Model] {
            guard let model = models.first else { return [] }
            return self.transform(entry: model, of: models)
        }
        
        private func transform(parent: Model) {
            let logger = Logging.createLogger(category: .todo(.refactor("")))
            os_log(.info, log: logger, "We should consider ")
            let entries = self.findSimilar(parent: parent)
            let results = entries.flatMap(self.transform(models:))
            // TODO: Refactor easyRelax.
            // It is a complex shit. No more.
            // we can't include one (!) metablock in another metablock.
            // instead, you should include
            if results.count == 1 && Inspector.isNumberedList(results[0]) && Inspector.isNumberedList(parent) {
                parent.update(results[0].blocks)
                return
            }
            parent.update(results)
        }
        
        public func transform(root: Model) -> Model {
            transform(parent: root)
            return root
        }
    }
}

extension BlockModels.Transformer {
    struct FinalTransformer {
        private var fromListToTree = FromListToTreeTransformer()
        private var applyNumberedList = ApplyNumberedListTransformer()
            
        func transform(_ information: [Information], rootId: MiddlewareBlockInformationModel.Id? = nil) -> Model {
            if let rootId = rootId {
                return applyNumberedList.transform(root: fromListToTree.fromList(information: information, rootId: rootId))
            }
            else {
                return applyNumberedList.transform(root: fromListToTree.fromList(information: information))
            }
        }
    }
}
