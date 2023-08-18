import AnytypeCore

extension Array {
    func reordered<T: Comparable>(
        by order: [T],
        transform: (Element) -> T
    ) -> [Element] {
        var newArray = self
        newArray.reorder(by: order, transform: transform)
        return newArray
    }
    
    mutating func reorder<T: Comparable>(
        by order: [T],
        transform: (Element) -> T
    ) {
        sort { a, b in
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
    
    func reorderedStable<T: Comparable>(
        by order: [T],
        transform: (Element) -> T
    ) -> [Element] {
        var newArray = self
        newArray.reorderStable(by: order, transform: transform)
        return newArray
    }
    
    mutating func reorderStable<T: Comparable>(
        by order: [T],
        transform: (Element) -> T
    ) {
        sort { a, b in
            let transformedA = transform(a)
            let transformedB = transform(b)
            
            guard let first = order.firstIndex(of: transformedA),
                  let second = order.firstIndex(of: transformedB) else {
                return false
            }

            return first < second
        }
    }
    
    mutating func moveElement(from: Index, to: Index) {
        guard from <= count else {
            anytypeAssertionFailure("Move element bigger", info: ["from": "\(from)", "count": "\(count)"])
            return
        }
        
        let element = remove(at: from)
        
        if to <= count {
            insert(element, at: to)
        } else {
            append(element)
        }
    }

    func first<T>(applying condition: (Element) -> T?) -> T? {
        var item: T?
        for element in self {
            if let foundedItem = condition(element) {
                item = foundedItem
                break
            }
        }

        return item
    }
}
