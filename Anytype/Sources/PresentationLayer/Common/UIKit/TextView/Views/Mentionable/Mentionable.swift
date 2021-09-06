import UIKit

protocol Mentionable {
    
    @discardableResult func removeMentionIfNeeded(
        replacementRange: NSRange,
        replacementText: String
    ) -> Bool
    
    func insert(
        _ mention: MentionObject,
        from: UITextPosition,
        to: UITextPosition,
        font: AnytypeFont
    )
}
