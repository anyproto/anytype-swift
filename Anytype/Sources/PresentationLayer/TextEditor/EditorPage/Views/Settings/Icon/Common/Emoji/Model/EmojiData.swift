struct EmojiData: Codable, Hashable {
    let emoji: String
    let description: String
    let category: String
    let aliases: [String]
    let tags: [String]
    let unicode_version: String
    
    var searchTerms: [String] {
        [ description] + aliases + tags
    }
}
