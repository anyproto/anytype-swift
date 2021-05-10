//
//  ArrayExtension.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import BlocksModels

extension Array where Element: Equatable {
    
    /// Add to array only uniq element
    /// - Parameter newElement: new element
    mutating func appendUniq(_ newElement: Element) {
        if !self.contains(newElement) {
            self.append(newElement)
        }
    }
}

// Reorder Array by predefined order.
extension Array {
        
    /// Reorder Array by order in custom properties of array by finding index of property.
    /// Best usage is the following:
    ///
    /// 1. Define property of array ( For example, name of person ).
    /// 2. Define a transform that find element in this collection (firstIndex/lastIndex)
    /// 3. Implement transform:
    ///
    /// ```
    /// findInCollection: {(value, collection) in
    ///   collection.firstIndex(of: value.name)
    ///   ///   collection.lastIndex(of: value.name)
    /// }
    /// ```
    ///
    /// Reorder!
    ///
    /// - Parameters:
    ///   - order: Order of properties/features
    ///   - findInCollection: A transform that first extract feature and return an index of this feature.
    /// - Returns: Reordered array.
    func reordered<T: Equatable>(by order: [T], findInCollection: (Element, [T]) -> Array<T>.Index?) -> [Element] {
        self.sorted { (lhs, rhs) -> Bool in
            guard let leftIndex = findInCollection(lhs, order), let rightIndex = findInCollection(rhs, order) else {
                return false
            }
            return leftIndex < rightIndex
        }
    }
    
    /// Reorder Array by order in custom properties of array.
    /// - Parameters:
    ///   - order: Order of properties/features.
    ///   - transform: Transform that extract a feature.
    /// - Returns: Reordered array.
    func reordered<T: Comparable>(by order: [T], transform: (Element) -> T?) -> [Element] {
        self.sorted { (lhs, rhs) -> Bool in
            guard let leftIndex = transform(lhs), let rightIndex = transform(rhs) else {
                return false
            }
            return leftIndex < rightIndex
        }
    }
    
    /// Safe access to elements by arbitrary index
    ///
    /// - Parameters:
    /// - index: Index to access element
    subscript(safe index: Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        }
        return nil
    }
}

extension Array where Element == BlockId {
    
    /// Compare old and new childrenIds and extract added, deleted, moved operations
    ///
    /// - Parameters:
    ///   - newChildrenIds: New children ids received after any event
    ///   - parentBlockId: Block id which owns children
    ///   
    /// - Returns: Updates
    func updates(with newChildrenIds: [Element],
                 parentBlockId: BlockId) -> BlockChildrenIdsUpdates {
        let diff = newChildrenIds.difference(from: self)
        let moves = diff.inferringMoves().insertions
        let movedBlockIds = Set(moves.map { $0.element })
        let filteredInsertions = diff.insertions.filter { !movedBlockIds.contains($0.element) }
        let filteredRemovals = diff.removals.filter { !movedBlockIds.contains($0.element) }
        return BlockChildrenIdsUpdates(added: filteredInsertions.changes(with: parentBlockId,
                                                                         newChildrenIds: newChildrenIds),
                                       deleted: filteredRemovals.map { $0.element },
                                       moved: moves.changes(with: parentBlockId,
                                                            newChildrenIds: newChildrenIds))
    }
}

extension Array where Element == CollectionDifference<BlockId>.Change {
    
    private func changes(with parentBlockId: BlockId,
                         newChildrenIds: [BlockId]) -> [EventHandlerUpdateChange] {
        // Here we just create data structures describe where objects must be located
        // relative to each other, without indices, for example
        // old children ids - ["a", "b", "c"], new children ids - ["a", "d", "c"]
        // "d" should be placed after "a", instead of "d" should be placed at index 1
        map {
            let afterBlockId = $0.offset == 0 ? parentBlockId : newChildrenIds[$0.offset - 1]
            return EventHandlerUpdateChange(targetBlockId: $0.element,
                                            afterBlockId: afterBlockId)
        }
    }
}
