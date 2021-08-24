enum ObjectIconType: Hashable {
    
    case basic(String)
    case profile(Profile)
    
    case emoji(IconEmoji)
    
}

// MARK: - ProfileIcon

extension ObjectIconType {
    
    enum Profile: Hashable {
        case imageId(String)
        case character(Character)
    }
    
}
