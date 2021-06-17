//
//  BlockModel+Updater+Relaxing.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let blockModelsUpdaterRelaxing: Self = "BlockModels.Updater.Relaxing"
}

extension BlockModels.Updater {
    class Relaxing {
        // MARK: Variables
        private var finder: BlockModels.Finder<Wrapped>?
        
        func update(finder: BlockModels.Finder<Wrapped>?) -> Self {
            self.finder = finder
            return self
        }
        
        // MARK: Initialization
        init() {}
        
        // MARK: Actions
        enum Action {
            // TODO: rethink strategy.
            // do we really care about siblings here?
            case update(Key, Model)
            case insert(Key, Model)
            case delete(Key)
            func key() -> Key {
                switch self {
                case let .update(value): return value.0
                case let .insert(value): return value.0
                case let .delete(value): return value
                }
            }
        }
        
        // MARK: Relax
        enum Relax {
            case divide(Key?, Key, Key?) // after insertion or updating
            case merge(Key?, Key, Key?) // after deletion or updating
        }
        
        // MARK: Find
        private func find(parent: Model, entry atKey: Key) -> Model? {
            self.findKey(parent: parent, entry: atKey).flatMap({self.finder?.find($0)})
        }
        
        private func findKey(parent: Model, entry atKey: Key) -> Key? {
            guard let last = atKey.last else { return nil }
            guard parent.blocks.indices.contains(last.item) else { return nil }
            return atKey
        }
        
        private func findKeys(parent: Model, siblings forKey: Key) -> (Key?, Key?) {
            guard let last = forKey.last else { return (nil, nil) }
            let left = Array(forKey.dropLast() + [.init(item: last.item - 1, section: last.section)])
            let right = Array(forKey.dropLast() + [.init(item: last.item + 1, section: last.section)])
            return (self.findKey(parent: parent, entry: left), self.findKey(parent: parent, entry: right))
        }
        
        private func find(parent: Model, siblings forKey: Key) -> (Model?, Model?) {
            let keys = self.findKeys(parent: parent, siblings: forKey)
            return (keys.0.flatMap({self.finder?.find($0)}), keys.1.flatMap({self.finder?.find($0)}))
        }
        
        private typealias Inspector = BlockModels.Utilities.Inspector

        // MARK: Match
        private func matchBlocks(_ lhs: Model, _ rhs: Model) -> Bool {
            // if they are both numbered or numbered list OR they are not numbered.
            return ((Inspector.isNumberedList(lhs) || Inspector.isNumbered(lhs)) == (Inspector.isNumberedList(rhs) || Inspector.isNumbered(rhs)))
        }
        
        private func findSimilar(parent: Model) -> [[Model]] {
            return DataStructures.GroupBy.group(parent.blocks as! [Model], by: self.matchBlocks)
        }
        
        // MARK: EasyRelax
        private func easyRelax(entry: Model, of cluster: [Model]) -> [Model] {
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
                let result = cluster.reduce([Model]()) { (result, value) in
                    var result = result
                    if Inspector.isNumbered(value) {
                        result.append(value)
                    }
                    else if Inspector.isNumberedList(value) {
                        result.append(contentsOf: value.blocks as! [Model])
                    }
                    return result
                }
                block.update(result)
                
                return [block]
            }
            return cluster
        }
        
        private func easyRelax(models: [Model]) -> [Model] {
            guard let model = models.first else { return [] }
            return self.easyRelax(entry: model, of: models)
        }
        
        public func easyRelax(parent: Model) {
            let logger = Logging.createLogger(category: .todo(.refactor("")))
            os_log(.info, log: logger, "Refactor following code. We should remove `.easyRelax` as expensive. relax(parent:action:) is cheap.")
            let entries = self.findSimilar(parent: parent)
            let results = entries.flatMap(self.easyRelax(models:))
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
        
        // MARK: Relax
        // Too complex. Do it later.
        public func relax(parent: Model, action: Action) -> Relax? {
            // we don't care about parent block type. we only care about types of siblings
            let targetKey = action.key()
            
            let (left, right) = self.find(parent: parent, siblings: targetKey)
            
            // 1. Lonely key in parent.
            if left == nil && right == nil { return nil }
            
            // 2. Check if parent is numbered list.
            let parentIsNumberedList = BlockModels.Utilities.Inspector.isNumberedList(parent)
            
            // 2. Not lonely key.
            switch action {
            case .insert: return nil
                if parentIsNumberedList {
                    // we should check if our new block is numbered list.
                }
            case .update: return nil// check that our model is
            case .delete: return nil
            }
            
            return nil
        }
    }
}
