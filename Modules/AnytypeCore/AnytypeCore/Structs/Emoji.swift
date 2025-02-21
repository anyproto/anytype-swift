public struct Emoji: Hashable, Codable, Sendable, Identifiable {
    
    public let value: String
    
    // MARK: - Initializer
    
    public init?(_ value: String?) {
        guard let value = value?.trimmed, value.isNotEmpty else { return nil }
        
        self.value = value
    }
    
    public static let lamp = Emoji("💡")!
    
    public var id: String { value }
}
