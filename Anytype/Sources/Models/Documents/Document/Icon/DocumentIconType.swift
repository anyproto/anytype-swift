enum DocumentIconType: Hashable {
    
    case basic(Basic)
    case profile(Profile)
    
    case emoji(IconEmoji)
    
}

// MARK: - BasicIcon

extension DocumentIconType {
    
    enum Basic: Hashable {
        case imageId(String)
        
    }

}

// MARK: - ProfileIcon

extension DocumentIconType {
    
    enum Profile: Hashable {
        case imageId(String)
        case placeholder(Character)
    }
    
}
