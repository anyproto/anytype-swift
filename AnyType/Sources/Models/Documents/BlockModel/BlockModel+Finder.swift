//
//  BlockModel+Finder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlockModels {
    class Finder<Wrapped: BlockModels.Block.RealBlock> {
        typealias Model = Wrapped
        typealias Key = Wrapped.FullIndex
        var value: Wrapped
        var indexDictionary: DataStructures.IndexDictionary<Key> = .init()
        
        func configured(_ value: Wrapped) -> Self {
            self.value = value
            return self
        }
        init(value: Wrapped) {
            self.value = value
        }
    }
}

// MARK: GetModel
extension BlockModels.Finder {
    /// Description
    ///
    /// Note
    ///
    /// We could catch a situation where model.indexPath is equal to index.s
    ///
    /// It CAN happens in case of Root node.
    ///
    /// FullPath really contains FULL path ( all nodes to root including ).
    /// Thus, we should skip root, of course.
    ///
    /// Later
    ///
    /// To guard yourself against side effects, add later ```model.isRoot``` check.
    /// - Parameters:
    ///   - model: The parent model in which we are looking for child.
    ///   - index: The indexPath which points to a child in ```model``` ( parent ) node.
    func getModel(_ model: Model?, _ index: Key.Element?) -> Model? {
        guard let index = index, let model = model else { return nil }
        if model.indexPath == index {
            return model
        }
        return model.find(index) as? Wrapped
    }
}

// MARK: Find
extension BlockModels.Finder {
    fileprivate func find(_ block: Model?, _ fullIndex: Key, _ tailLength: UInt = 0) -> Model? {
        guard block != nil else { return nil }
        if fullIndex.count < tailLength { return nil }
        if fullIndex.count == tailLength { return block }
        return find(getModel(block, fullIndex.first), Array(fullIndex.dropFirst()), tailLength)
    }
}

// MARK: Find Self
extension BlockModels.Finder {
    public func find(_ fullIndex: Key) -> Model? {
        find(self.value, fullIndex, 0)
    }
}

// MARK: Find Parent
extension BlockModels.Finder {
    public func findParent(_ fullIndex: Key) -> Model? {
        find(self.value, fullIndex, 1)
    }
}

// MARK: Find findGrandParent
extension BlockModels.Finder {
    public func findGrandParent(_ fullIndex: Key) -> Model? {
        find(self.value, fullIndex, 2)
    }
}
