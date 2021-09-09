
import UIKit

struct ContentConfigurationWithEmoji: Hashable {
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

