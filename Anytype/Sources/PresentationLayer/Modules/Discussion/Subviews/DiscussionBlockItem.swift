import SwiftUI

enum DiscussionBlockItem: Equatable, Hashable, Identifiable {
    case text(id: Int, content: AttributedString)
    case quote(id: Int, content: AttributedString)
    case callout(id: Int, content: AttributedString)
    case checkbox(id: Int, content: AttributedString, checked: Bool)
    case bulleted(id: Int, content: AttributedString)
    case numbered(id: Int, content: AttributedString)
    case toggle(id: Int, content: AttributedString)
    case unsupported(id: Int, blockName: String)

    var id: Int {
        switch self {
        case .text(let id, _),
             .quote(let id, _),
             .callout(let id, _),
             .checkbox(let id, _, _),
             .bulleted(let id, _),
             .numbered(let id, _),
             .toggle(let id, _),
             .unsupported(let id, _):
            return id
        }
    }

    var plainText: String? {
        switch self {
        case .text(_, let content),
             .quote(_, let content),
             .callout(_, let content),
             .checkbox(_, let content, _),
             .bulleted(_, let content),
             .numbered(_, let content),
             .toggle(_, let content):
            let text = NSAttributedString(content).string
            return text.isEmpty ? nil : text
        case .unsupported:
            return nil
        }
    }
}

extension [DiscussionBlockItem] {
    var plainText: String {
        compactMap(\.plainText).joined(separator: "\n")
    }

    var hasContent: Bool {
        contains { $0.plainText != nil }
    }
}
