import UIKit


final class EmojiProvider {
        
    static let shared = EmojiProvider()
    
    // MARK: - Private variables
    
    private(set) lazy var emojiGroups: [EmojiGroup] = loadEmojiGroups()
    
    // MARK: - Internal functions
    
    func filteredEmojiGroups(keyword: String) -> [EmojiGroup] {
        guard !keyword.isEmpty else { return emojiGroups }
        
        let lowercasedKeyword = keyword.lowercased()
        
        let filteredGroups: [EmojiGroup] = emojiGroups.compactMap { group in
            let filteredEmoji: [Emoji] = group.emojis.filter { emoji in
                emoji.searchTerms.first { searchTerm in
                    searchTerm.lowercased().range(of: lowercasedKeyword).isNotNil
                }.isNotNil
            }
            
            guard !filteredEmoji.isEmpty else { return nil }
            
            return EmojiGroup(
                name: group.name,
                emojis: filteredEmoji
            )
        }
        
        return filteredGroups
    }
    
    func randomEmoji() -> Emoji? {
        emojiGroups.randomElement()?.emojis.randomElement()
    }
    
}

// MARK: - Private extension

private extension EmojiProvider{
    
    func loadEmojiGroups() -> [EmojiGroup] {
        guard let asset = NSDataAsset(name: "Emoji/EmojiData") else {
            fatalError("Missing data asset: EmojiData")
        }
        
        let emojis = try! JSONDecoder().decode([Emoji].self, from: asset.data)
        
        var groups = [EmojiGroup]()
        
        emojis.forEach { emoji in
            guard let index = groups.firstIndex(where: { $0.name == emoji.category }) else {
                groups.append(EmojiGroup(name: emoji.category, emojis: [emoji]))
                return
            }
            groups[index] = groups[index].updated(emoji: emoji)
        }

        return groups
    }

}
