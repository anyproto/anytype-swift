//
//  DataStructures+GroupBy.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 02.03.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
extension DataStructures {
    /// GroupBy
    /// Single-function structure.
    struct GroupBy {
        /// group(_:by:)
        /// - Parameters:
        ///   - array: array of items that could be grouped by some feature or property.
        ///   - by: a closure argument that tells which elements are grouped or not.
        /// NOTE: You could change result of this function to sequence to lazy evaluate it.
        static func group<T>(_ array: [T], by: (T, T) -> Bool ) -> [[T]] {
            if array.isEmpty {
                return []
            }
            
            // 1. group together entries which are the "same" <by>-closure-argument.
            let remains = array.dropFirst()
            let prefix = array.prefix(1)
            let firstElements = Array(prefix)
            
            let grouped = remains.reduce([firstElements]) { (result, block) in
                var result = result
                if let lastGroup = result.last, let firstObject = lastGroup.first, by(firstObject, block) {
                    result = result.dropLast() + [(lastGroup + [block])]
                }
                else {
                    result.append([block])
                }
                return result
            }
            
            return grouped
        }
    }
}
