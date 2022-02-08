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
    
    mutating func moveElement(from: Index, to: Index) {
        let element = remove(at: from)
        insert(element, at: to)
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

extension Array where Element: Equatable {
    mutating func removeAllOccurrences(of element: Element) {
        self = filter { $0 != element }
    }
}
