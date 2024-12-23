import Foundation
import AnytypeCore

public enum MarkupType: Equatable, Hashable, CaseIterable, Sendable {
    case bold
    case italic
    case keyboard
    case strikethrough
    case underscored
    case textColor(MiddlewareColor)
    case backgroundColor(MiddlewareColor)
    case link(URL?)
    case linkToObject(String?)
    case mention(MentionObject)
    case emoji(Emoji)

    public func hash(into hasher: inout Hasher) {
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

    public static var allCases: [MarkupType] {
        return [.bold, italic, .keyboard, .strikethrough, .underscored, .textColor(.grey), .backgroundColor(.grey), .link(nil), .linkToObject(nil), .mention(.noDetails(blockId: ""))]
    }
    
    public func sameType(_ other: MarkupType) -> Bool {
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
    
    public func typeWithoutValue() -> MarkupType {
        return MarkupType.allCases.first { $0.sameType(self) } ?? self
    }
}
