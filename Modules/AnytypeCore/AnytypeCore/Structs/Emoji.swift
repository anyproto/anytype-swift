public struct Emoji: Hashable {
    
    public let value: String
    
    // MARK: - Initializer
    
    public init?(_ value: String?) {
        guard let value = value?.trimmed, value.isNotEmpty else {
            return nil
        }
        
        guard value.isSingleEmoji else {
            anytypeAssertionFailure("Not a single emoji: \(value)", domain: .iconEmoji)
            return nil
        }
        
        self.value = value
    }
    
    public static let `default` = Emoji("📄")!
}
