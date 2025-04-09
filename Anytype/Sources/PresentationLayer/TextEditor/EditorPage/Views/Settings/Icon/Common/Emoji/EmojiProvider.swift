import UIKit
import AnytypeCore


final class EmojiProvider: @unchecked Sendable {
        
    static let shared = EmojiProvider()
    
    // MARK: - Private variables
    
    private let lock = NSLock()
    private(set) lazy var emojiGroups: [EmojiGroup] = loadEmojiGroups()
    
    // MARK: - Internal functions
    
    func filteredEmojiGroups(keyword: String) -> [EmojiGroup] {
        lock.lock()
        defer { lock.unlock() }
        
        guard !keyword.isEmpty else { return emojiGroups }
        
        let lowercasedKeyword = keyword.lowercased()
        
        let filteredGroups: [EmojiGroup] = emojiGroups.compactMap { group in
            let filteredEmoji: [EmojiData] = group.emojis.filter { emoji in
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
    
    func randomEmoji() -> EmojiData? {
        lock.lock()
        defer { lock.unlock() }
        
        return emojiGroups.randomElement()?.emojis.randomElement()
    }
    
}

// MARK: - Private extension

private extension EmojiProvider {
    
    func loadEmojiGroups() -> [EmojiGroup] {
        // source https://github.com/github/gemoji/blob/master/db/emoji.json
        guard let asset = NSDataAsset(name: "Emoji/EmojiData") else {
            fatalError("Missing data asset: EmojiData")
        }
        
        let emojis = try! JSONDecoder().decode([EmojiData].self, from: asset.data)
        
        var groups = [EmojiGroup]()
        
        emojis.forEach { emoji in
            guard emojiSupproted(emoji) else { return }
            
            guard let index = groups.firstIndex(where: { $0.name == emoji.category }) else {
                groups.append(EmojiGroup(name: emoji.category, emojis: [emoji]))
                return
            }
            groups[index] = groups[index].updated(emoji: emoji)
        }

        return groups
    }

    func emojiSupproted(_ emoji: EmojiData) -> Bool {
        guard emoji.unicode_version.isNotEmpty else {
            return true // some data is missing for old emojis
        }
        
        let majorVersion = emoji.unicode_version.split(separator: ".").first.flatMap { String($0) } ?? emoji.unicode_version
        guard let intVersion = Int(majorVersion) else {
            anytypeAssertionFailure("Cannot parse emoji", info: ["unicode_version": emoji.unicode_version])
            return false
        }
        
        let supportedEmojiVersion = 12
        return intVersion <= supportedEmojiVersion
    }
}
