import Foundation
import UIKit
import Combine
import os
import BlocksModels


// Unused code, it was here before


/*
/// Visual style of left view ( image or label with emoji ).
enum PageTitleStyle {
    typealias Emoji = String
    case noContent
    case noEmoji
    case emoji(Emoji)
    var resource: String {
        switch self {
        case .noContent: return "TextEditor/Style/Page/empty"
        case .noEmoji: return "TextEditor/Style/Page/withoutEmoji"
        case let .emoji(value): return value
        }
    }
}

/// Struct State that will take care of all flags and data.
/// It is equal semantically to `Payload` that will delivered from outworld ( view model ).
/// It contains necessary information for view as emoji, title, archived, etc.
///
struct PageTitleState {
    static let empty = PageTitleState(archived: false, hasContent: false, title: nil, emoji: nil)
    var archived: Bool
    var hasContent: Bool
    var title: String?
    var emoji: String?

    var style: PageTitleStyle {
        switch (hasContent, emoji) {
        case (false, .none): return .noContent
        case (true, .none): return .noEmoji
        case let (_, .some(value)): return .emoji(value)
        }
    }
}
*/
