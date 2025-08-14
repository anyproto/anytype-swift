import Foundation

public extension Array {
    func uniqued() -> [Element] where Element: Hashable {
        var result: [Element] = []
        for element in self {
            if !result.contains(element) {
                result.append(element)
            }
        }
        return result
    }
    
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

public extension Array where Element: Hashable {
    static func - (a: Self, b: Self) -> Self {
        let set = Set(b)
        return a.filter { !set.contains($0) }
    }
}
