
import UIKit

struct MentionWithEmojiContentConfiguration {
    
    let emoji: String
    let name: String?
    let description: String?
}

extension MentionWithEmojiContentConfiguration: UIContentConfiguration {
    
    func makeContentView() -> UIView & UIContentView {
        MentionWithEmojiContentView(contentConfiguration: self)
    }
    
    func updated(for state: UIConfigurationState) -> MentionWithEmojiContentConfiguration {
        self
    }
}

extension MentionWithEmojiContentConfiguration: Hashable {
    
    static func == (lhs: MentionWithEmojiContentConfiguration,
                    rhs: MentionWithEmojiContentConfiguration) -> Bool {
        lhs.emoji == rhs.emoji && lhs.name == rhs.name && lhs.description == rhs.description
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(emoji)
        hasher.combine(name)
        hasher.combine(description)
    }
}
