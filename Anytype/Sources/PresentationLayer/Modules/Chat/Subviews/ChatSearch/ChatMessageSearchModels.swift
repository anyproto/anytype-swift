import Foundation
import SwiftUI

enum ChatMessageSearchMode: Equatable {
    case hidden
    // Fullscreen cover with the query input and the results list
    case fullscreen
    // Results navigation over the visible chat: read-only query bar and up/down buttons
    case inline
}

struct ChatMessageSearchResultData: Identifiable, Equatable {
    let id: String
    let authorIcon: Icon
    let authorName: String
    let snippet: AttributedString
    let dateText: String
}
