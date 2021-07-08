enum DocumentIconType: Hashable {
    
    case basic(Basic)
    case profile(Profile)
    
    init?(emoji: String) {
        if let emoji = IconEmoji(emoji) {
            self = .basic(.emoji(emoji))
        } else {
            return nil
        }
    }
}

// MARK: - BasicIcon

extension DocumentIconType {
    
    enum Basic: Hashable {
        case imageId(String)
        case emoji(IconEmoji)
    }

}

// MARK: - ProfileIcon

extension DocumentIconType {
    
    enum Profile: Hashable {
        case imageId(String)
        case placeholder(Character)
    }
    
}
