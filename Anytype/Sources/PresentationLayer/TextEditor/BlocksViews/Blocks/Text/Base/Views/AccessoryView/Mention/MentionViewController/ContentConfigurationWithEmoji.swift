
import UIKit

struct ContentConfigurationWithEmoji {
    
    let emoji: String
    let name: String?
    let description: String?
}

extension ContentConfigurationWithEmoji: UIContentConfiguration {
    
    func makeContentView() -> UIView & UIContentView {
        ContentViewWithEmoji(contentConfiguration: self)
    }
    
    func updated(for state: UIConfigurationState) -> ContentConfigurationWithEmoji {
        self
    }
}

extension ContentConfigurationWithEmoji: Hashable {
    
    static func == (lhs: ContentConfigurationWithEmoji,
                    rhs: ContentConfigurationWithEmoji) -> Bool {
        lhs.emoji == rhs.emoji && lhs.name == rhs.name && lhs.description == rhs.description
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(emoji)
        hasher.combine(name)
        hasher.combine(description)
    }
}
