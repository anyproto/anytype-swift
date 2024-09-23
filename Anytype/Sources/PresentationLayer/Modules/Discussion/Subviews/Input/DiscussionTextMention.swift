import Foundation

enum DiscussionTextMention: Equatable {
    case search(_ text: String, _ replacementRange: NSRange)
    case finish
}
