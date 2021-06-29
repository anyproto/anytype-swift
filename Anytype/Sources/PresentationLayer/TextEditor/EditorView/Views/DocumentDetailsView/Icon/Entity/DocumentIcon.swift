enum DocumentIcon: Hashable {
    case emoji(IconEmoji)
    case imageId(String)
    
    init?(emoji: String) {
        if let iconEmoji = IconEmoji(emoji) {
            self = .emoji(iconEmoji)
        } else {
            return nil
        }
    }
}
