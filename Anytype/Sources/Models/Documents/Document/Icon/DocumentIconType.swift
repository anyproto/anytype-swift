enum DocumentIconType: Hashable {
    
    case basic(Basic)
    case profile(Profile)
    
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
