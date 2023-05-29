import UIKit
import BlocksModels
import SwiftUI
import AnytypeCore

enum MarkupType: Equatable, Hashable, CaseIterable {
    case bold
    case italic
    case keyboard
    case strikethrough
    case underscored
    case textColor(UIColor)
    case backgroundColor(UIColor)
    case link(URL?)
    case linkToObject(BlockId?)
    case mention(MentionData)
    case emoji(Emoji)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .textColor(let value):
            hasher.combine(value)
        case .backgroundColor(let value):
            hasher.combine(value)
        case let .link(value):
            hasher.combine(value)
        case let .linkToObject(value):
            hasher.combine(value)
        case let .mention(value):
            hasher.combine(value)
        case let .emoji(value):
            hasher.combine(value)
        case .bold, .italic, .keyboard, .strikethrough, .underscored:
            break
        }
    }

    static var allCases: [MarkupType] {
        return [.bold, italic, .keyboard, .strikethrough, .underscored, .textColor(.Text.secondary), .backgroundColor(.Text.secondary), .link(nil), .linkToObject(nil), .mention(MentionData.noDetails(blockId: ""))]
    }
    
    func sameType(_ other: MarkupType) -> Bool {
        switch (self, other) {
        case (.bold, .bold),
            (.italic, .italic),
            (.keyboard, .keyboard),
            (.strikethrough, .strikethrough),
            (.underscored, .underscored),
            (.textColor, .textColor),
            (.backgroundColor, .backgroundColor),
            (.link, .link),
            (.linkToObject, .linkToObject),
            (.mention, .mention),
            (.emoji, .emoji):
            return true
        default:
            return false
        }
    }
    
    func typeWithoutValue() -> MarkupType {
        return MarkupType.allCases.first { $0.sameType(self) } ?? self
    }
}
