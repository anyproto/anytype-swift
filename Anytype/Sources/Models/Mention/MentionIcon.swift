enum MentionIcon {
    case objectIcon(ObjectIconType)
    case checkmark(Bool)
}

extension MentionIcon {
    
    init?(emoji: String) {
        guard let emoji = IconEmoji(emoji) else { return nil }
        
        self = .objectIcon(.emoji(emoji))
    }
    
}
