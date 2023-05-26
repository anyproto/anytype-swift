import Services
import ProtobufMessages
import AnytypeCore
import UIKit

enum MarkStyleActionConverter {
    
    static func asModel(tuple: MiddlewareTuple) -> MarkupType? {
        switch tuple.attribute {
        case .strikethrough:
            return .strikethrough
        case .keyboard:
            return .keyboard
        case .italic:
            return .italic
        case .bold:
            return .bold
        case .underscored:
            return .underscored
        case .link:
            let urlString = tuple.value.trimmingCharacters(in: .whitespacesAndNewlines)
            return .link(URL(string: urlString))

        case .textColor:
            guard let middlewareColor = MiddlewareColor(rawValue: tuple.value) else {
                return nil
            }
            return .textColor(UIColor.Dark.uiColor(from: middlewareColor))

        case .backgroundColor:
            guard let middlewareColor = MiddlewareColor(rawValue: tuple.value) else {
                return nil
            }
            return .backgroundColor(UIColor.VeryLight.uiColor(from: middlewareColor))

        case .mention:
            guard let details = ObjectDetailsStorage.shared.get(id: tuple.value) else {
                return .mention(.noDetails(blockId: tuple.value))
            }
            return .mention(MentionData(details: details))

        case .object:
            return .linkToObject(tuple.value)

        case .emoji:
            guard let emoji = Emoji(tuple.value) else {
                anytypeAssertionFailure("Unrecognized emoji \(tuple.value)", domain: .markStyleConverter)
                return nil
            }
            return .emoji(emoji)

        case .UNRECOGNIZED(let value):
            anytypeAssertionFailure("Unrecognized markup \(value)", domain: .markStyleConverter)
            return nil
        }
    }
}
