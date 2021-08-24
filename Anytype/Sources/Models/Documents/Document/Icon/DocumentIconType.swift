enum DocumentIconType: Hashable {
    
    case basic(String)
    case profile(Profile)
    
    case emoji(IconEmoji)
    
}

// MARK: - ProfileIcon

extension DocumentIconType {
    
    enum Profile: Hashable {
        case imageId(String)
        case character(Character)
    }
    
}
