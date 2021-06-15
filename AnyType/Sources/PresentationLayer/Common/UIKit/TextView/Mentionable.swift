import Foundation

protocol Mentionable {
    
    func removeMentionIfNeeded(replacementRange: NSRange,
                               replacementText: String)
}
