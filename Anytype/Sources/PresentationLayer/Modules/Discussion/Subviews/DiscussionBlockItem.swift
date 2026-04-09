import SwiftUI
import Services

enum DiscussionBlockItem: Equatable, Hashable, Identifiable {
    case text(id: Int, content: AttributedString)
    case title(id: Int, content: AttributedString)
    case heading(id: Int, content: AttributedString)
    case subheading(id: Int, content: AttributedString)
    case quote(id: Int, content: AttributedString)
    case callout(id: Int, content: AttributedString)
    case checkbox(id: Int, content: AttributedString, checked: Bool)
    case bulleted(id: Int, content: AttributedString)
    case numbered(id: Int, content: AttributedString, number: Int)
    case toggle(id: Int, content: AttributedString)
    case image(id: Int, details: MessageAttachmentDetails)
    case video(id: Int, details: MessageAttachmentDetails)
    case file(id: Int, details: MessageAttachmentDetails)
    case linkObject(id: Int, details: MessageAttachmentDetails)
    case bookmark(id: Int, details: ObjectDetails)
    case embed(id: Int, data: EmbedContentData)
    case divider(id: Int)
    case unsupported(id: Int, blockName: String)

    var id: Int {
        switch self {
        case .text(let id, _),
             .title(let id, _),
             .heading(let id, _),
             .subheading(let id, _),
             .quote(let id, _),
             .callout(let id, _),
             .checkbox(let id, _, _),
             .bulleted(let id, _),
             .numbered(let id, _, _),
             .toggle(let id, _),
             .image(let id, _),
             .video(let id, _),
             .file(let id, _),
             .linkObject(let id, _),
             .bookmark(let id, _),
             .embed(let id, _),
             .divider(let id),
             .unsupported(let id, _):
            return id
        }
    }

    var plainText: String? {
        switch self {
        case .text(_, let content),
             .title(_, let content),
             .heading(_, let content),
             .subheading(_, let content),
             .quote(_, let content),
             .callout(_, let content),
             .checkbox(_, let content, _),
             .bulleted(_, let content),
             .numbered(_, let content, _),
             .toggle(_, let content):
            let text = NSAttributedString(content).string
            return text.isEmpty ? nil : text
        case .image, .video, .file, .linkObject, .bookmark, .embed, .divider, .unsupported:
            return nil
        }
    }

    var topSpacing: CGFloat {
        switch self {
        case .title: return 20
        case .heading: return 16
        case .subheading: return 12
        case .quote: return 12
        case .text, .callout, .checkbox, .bulleted, .numbered, .toggle,
             .image, .video, .file, .linkObject, .bookmark, .embed, .divider, .unsupported:
            return 8
        }
    }

    var bottomSpacing: CGFloat {
        switch self {
        case .quote: return 12
        case .text, .title, .heading, .subheading, .callout, .checkbox, .bulleted, .numbered, .toggle,
             .image, .video, .file, .linkObject, .bookmark, .embed, .divider, .unsupported:
            return 0
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

// MARK: - Spacing calculation

enum DiscussionBlockSpacing {
    static let firstBlockTopSpacing: CGFloat = 8

    /// Computes the top padding for each block in a sequence.
    /// - First block (index 0) always gets `firstBlockTopSpacing` (8).
    /// - Subsequent blocks get `max(block.topSpacing, previousBlock.bottomSpacing)`.
    static func topPaddings(for blocks: [DiscussionBlockItem]) -> [CGFloat] {
        blocks.enumerated().map { index, block in
            if index == 0 {
                return firstBlockTopSpacing
            }
            let previous = blocks[index - 1]
            return max(block.topSpacing, previous.bottomSpacing)
        }
    }
}
