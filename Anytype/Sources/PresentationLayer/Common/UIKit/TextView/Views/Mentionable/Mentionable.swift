import UIKit

protocol Mentionable {
    
    @discardableResult func removeMentionIfNeeded(
        replacementRange: NSRange,
        replacementText: String
    ) -> Bool
}
