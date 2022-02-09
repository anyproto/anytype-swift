import AnytypeCore

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
        guard from <= count else {
            anytypeAssertionFailure("Move element \(from) bigger then \(count)", domain: .arrayExtension)
            return
        }
        
        let element = remove(at: from)
        
        if to <= count {
            insert(element, at: to)
        } else {
            append(element)
        }
    }
}

extension Array where Element: Equatable {
    mutating func removeAllOccurrences(of element: Element) {
        self = filter { $0 != element }
    }
}
