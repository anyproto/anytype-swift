public struct Emoji: Hashable, Codable {
    
    public let value: String
    
    // MARK: - Initializer
    
    public init?(_ value: String?) {
        guard let value = value?.trimmed, value.isNotEmpty else {
            return nil
        }
        
        let emoji = value.first { $0.isEmoji }
        guard let emoji = emoji else {
            anytypeAssertionFailure("Not an emoji: \(value)", domain: .iconEmoji)
            return nil
        }
        
        self.value = String(emoji)
    }
    
    public static let `default` = Emoji("📝")!
    public static let lamp = Emoji("💡")!
}
