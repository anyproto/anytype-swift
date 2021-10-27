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

extension Array {
    
    /// Safe access to elements by arbitrary index
    ///
    /// - Parameters:
    /// - index: Index to access element
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
 
}

extension Array {
    
  func reordered<T: Comparable>(
    by order: [T],
    transform: (Element) -> T
  ) -> [Element] {
    sorted { a, b in
      let transformedA = transform(a)
      let transformedB = transform(b)
      guard let first = order.firstIndex(of: transformedA) else {
        return false
      }
      guard let second = order.firstIndex(of: transformedB) else {
        return true
      }

      return first < second
    }
  }
    
}
