struct EmojiGroup: Hashable {
    
    let name: String
    let emojis: [EmojiData]
    
    func updated(emoji: EmojiData) -> EmojiGroup {
        EmojiGroup(name: name, emojis: emojis + [emoji])
    }
}
