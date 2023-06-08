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
}
