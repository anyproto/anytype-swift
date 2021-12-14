extension Array where Element == EmojiGroup {
    
    /// have less then 12 emoji in all groups
    var haveFewEmoji: Bool {
        first { $0.emojis.count >= 12 }.isNil
    }
    
    var flattenedList: [EmojiGroup] {
        [EmojiGroup(name: "", emojis: flatMap { $0.emojis })]
    }
}
