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
        
        guard value.isSingleEmoji else {
            anytypeAssertionFailure("Not a single emoji: \(value)", domain: .iconEmoji)
            return nil
        }
        
        self.value = value
    }
    
    static let `default` = IconEmoji("⚪️")!
}
