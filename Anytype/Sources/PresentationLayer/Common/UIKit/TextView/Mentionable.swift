import UIKit

protocol Mentionable {
    
    func removeMentionIfNeeded(replacementRange: NSRange,
                               replacementText: String)
    
    func insert(_ mention: MentionObject,
                from: UITextPosition,
                to: UITextPosition)
}
