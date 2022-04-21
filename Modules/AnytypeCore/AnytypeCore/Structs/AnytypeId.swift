import Foundation

public struct AnytypeId: Hashable {
    
    public let value: String
    
    // MARK: - Initializer
    
    public init?(_ value: String?) {
        guard let value = value?.trimmed, value.isNotEmpty else {
            return nil
        }
        
        self.value = value
    }
    
}
