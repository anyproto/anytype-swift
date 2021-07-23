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
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
    
}
