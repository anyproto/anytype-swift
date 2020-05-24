//
//  Emoji.swift
//  AnyType
//  EmojiManager
//  Created by Valentine Eyiubolu on 4/30/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit

extension EmojiPicker {

    public class Manager: NSObject {
        
        public enum Category: String, CaseIterable {
            case smileys = "Smileys & People" /// 😃
            case animals = "Animals & Nature" /// 🐻
            case food = "Food & Drink" /// 🍔
            case activity = "Activity" ///⚽
            case travel = "Travel & Places" ///🌇
            case objects = "Objects" /// 💡
            case symbols = "Symbols" /// 🔣
            case flags = "Flags" /// 🎌
            case ufo = "🛸 UFO 🛸" /// 🛸
        }

        public struct Emoji {
            var unicode: String
            var name: [String]
            var category: Category
            
            static func empty() -> Emoji {
                Emoji(unicode: "", name: [], category: .ufo)
            }
        }
        
        public lazy var emojis: [Emoji] = EmojiPicker.Manager.Loader.emojis()
        
        // TODO: Rewrite later
        /// Search emoji by keywords
        public func emojis(keywords: [String]) -> [Emoji] {
         
            var result: [Emoji] = []
           
            emojis.forEach { emoji in
                keywords.forEach { keyword in
                    emoji.name.forEach { (name) in
                        if name.lowercased().range(of: keyword.lowercased()) != nil {
                            result.append(emoji)
                        }
                    }
                }
            }
            
            return result
        }
        
        /// Return standard name for a emoji
        public func name(emoji: String) -> [String] {
            /// Swift 5 feature
            emoji.unicodeScalars.map({$0.properties.name ?? ""})
        }
        
        public func random() -> Emoji {
            emojis.randomElement() ?? Emoji.empty()
        }
        
    }
}

// MARK: - Emojis Loader
extension EmojiPicker.Manager {
    
    public class Loader {
        
        static func emojis() -> [Emoji] {

            guard let asset = NSDataAsset(name: "Emoji/EmojiData") else {
                fatalError("Missing data asset: EmojiData")
            }
            
            //TODO: Convert to emoji struct later
            guard let json = try? JSONSerialization.jsonObject(with: asset.data, options: .allowFragments) else {
                return []
            }
            
            guard let categories = json as? [[String : Any]] else {
                return []
            }
            
            let availableCategories: [Category] = Category.allCases
                  
            var emojis = [Emoji]()
            
            for dictionary in categories {
                guard let title = dictionary["title"] as? String else {
                    continue
                }
                
                guard let rawEmojis = dictionary["emojis"] as? [Any] else {
                    continue
                }
             
                guard let category = availableCategories.first(where: { $0.rawValue.lowercased() == title.lowercased() }) else {
                    continue
                }
                
                // Need to think about different colors emoji 👶👶🏾👶🏿
                // For now we handle only white skin, is that racism?
                for emojiUnicode in rawEmojis {
                    if let emoji = emojiUnicode as? String {
                        emojis.append(.init(unicode: emoji, name: emoji.unicodeScalars.map({$0.properties.name ?? ""}), category: category))
                    } else if let subEmojis = emojiUnicode as? [String], let emoji = subEmojis.first {
                        emojis.append(.init(unicode: emoji, name: emoji.unicodeScalars.map({$0.properties.name ?? ""}), category: category))
                    }
                }

            }
            
            return emojis
        }
        
    }

}
