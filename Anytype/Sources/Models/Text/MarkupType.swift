import UIKit
import BlocksModels
import SwiftUI

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
        case .bold, .italic, .keyboard, .strikethrough, .underscored:
            break
        }
    }

    static var allCases: [MarkupType] {
        return [.bold, italic, .keyboard, .strikethrough, .underscored, .textColor(.grayscale90), .backgroundColor(.grayscale90), .link(nil), .linkToObject(nil), .mention(MentionData.noDetails(blockId: ""))]
    }
}
