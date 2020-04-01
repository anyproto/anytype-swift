//
//  BlockModel+IndexWalker.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.03.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlockModels {
    /// Index Walker
    ///
    /// This class purpose is traversing through collection (tree).
    ///
    /// It could be replaced later by some Iterator.
    ///
    /// Types
    ///
    /// Self.Model - Our model
    ///
    /// Self.FullIndex - Our model full index [IndexPath] ( path from root to leaf ).
    ///
    class IndexWalker {
        typealias Model = BlockModels.Block.RealBlock
        typealias FullIndex = Model.FullIndex
    }
}

// MARK: Index Before
extension BlockModels.IndexWalker {
    private func index(before: FullIndex, includeParent: Bool) -> FullIndex {
        guard let lastPart = before.last else { return [] }
        
        let possibleValue = lastPart.item - 1
        guard possibleValue >= 0 else {
            if includeParent { return Array(before.dropLast()) }
            return []
        }
        
        return Array(before.dropLast()) + [.init(item: possibleValue, section: lastPart.section)]
    }
    
    func index(beforeModel model: Model, includeParent: Bool) -> FullIndex {
        index(before: model.getFullIndex(), includeParent: includeParent)
    }
}
