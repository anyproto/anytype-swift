import AnytypeCore

// TODO: - Move to AnytypeCore
// TODO: - Rename to `Emoji` or `Emojik` :)
struct IconEmoji: Hashable {
    
    let value: String
    
    // MARK: - Initializer
    
    init?(_ value: String?) {
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
    
    static let `default` = IconEmoji("⚪️")!
}
