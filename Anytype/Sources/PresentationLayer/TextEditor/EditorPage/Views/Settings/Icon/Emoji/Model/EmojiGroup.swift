struct EmojiGroup: Hashable {
    
    let name: String
    let emojis: [Emoji]
    
    func updated(emoji: Emoji) -> EmojiGroup {
        EmojiGroup(name: name, emojis: emojis + [emoji])
    }
}
