import Foundation

public struct DetailsEntry<V: Hashable> {
    
    public let value: V
    
    public init(value: V) {
        self.value = value
    }
       
}

extension DetailsEntry: Hashable {}
