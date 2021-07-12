import Foundation

public struct DetailsEntry<V: Hashable>: Hashable {
    
    public let value: V
    
    public init(value: V) {
        self.value = value
    }
       
}
