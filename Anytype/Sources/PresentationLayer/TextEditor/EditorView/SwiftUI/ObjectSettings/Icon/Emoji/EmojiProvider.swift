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
                !emoji.name.lowercased().range(of: lowercasedKeyword).isNil
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

        guard
            let json = try? JSONSerialization.jsonObject(
                with: asset.data,
                options: .allowFragments
            )
        else {
            return []
        }

        guard let categories = json as? [[String : Any]] else {
            return []
        }

        let emojiGroups: [EmojiGroup] = categories.compactMap { dictionary in
            guard
                let title = dictionary["title"] as? String,
                let rawEmojis = dictionary["emojis"] as? [Any]
            else {
                return nil
            }
            
            let emojis: [Emoji] = rawEmojis.compactMap { emojiUnicode in
                let emoji: String? = {
                    if let emoji = emojiUnicode as? String {
                        return emoji
                    }
                    else if let subEmojis = emojiUnicode as? [String], let emoji = subEmojis.first {
                        return emoji
                    }
                    
                    return nil
                }()
                
                guard let emojiSymbol = emoji else { return nil }
                
                return Emoji(
                    unicode: emojiSymbol,
                    name: emojiSymbol.unicodeScalars.first?.properties.name ?? ""
                )
            }
            
            return EmojiGroup(
                name: title,
                emojis: emojis
            )
        }
        
        return emojiGroups
    }

}
