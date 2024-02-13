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
    
     func contains<T>(_ object: T) -> Bool where T: Equatable {
         !self.filter {$0 as? T == object }.isEmpty
     }
}
