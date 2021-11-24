struct Emoji: Codable, Hashable {
    let emoji: String
    let description: String
    let category: String
    let aliases: [String]
    let tags: [String]
    
    var searchTerms: [String] {
        [ description] + aliases + tags
    }
}
