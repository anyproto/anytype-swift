import Foundation

enum ChatTextMention: Equatable {
    case search(_ text: String, _ replacementRange: NSRange)
    case finish
}
