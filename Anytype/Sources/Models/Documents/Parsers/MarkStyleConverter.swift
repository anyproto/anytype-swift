import Services
import ProtobufMessages
import AnytypeCore
import UIKit

enum MarkStyleActionConverter {
    
    static func asModel(document: BaseDocumentProtocol, tuple: MiddlewareTuple) -> MarkupType? {
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
            return .textColor(middlewareColor)

        case .backgroundColor:
            guard let middlewareColor = MiddlewareColor(rawValue: tuple.value) else {
                return nil
            }
            return .backgroundColor(middlewareColor)

        case .mention:
            guard let details = document.detailsStorage.get(id: tuple.value) else {
                return .mention(.noDetails(blockId: tuple.value))
            }
            return .mention(MentionObject(details: details))
        case .object:
            return .linkToObject(tuple.value)

        case .emoji:
            guard let emoji = Emoji(tuple.value) else {
                anytypeAssertionFailure("Unrecognized emoji")
                return nil
            }
            return .emoji(emoji)

        case .UNRECOGNIZED(let value):
            anytypeAssertionFailure("Unrecognized markup", info: ["value": "\(value)"])
            return nil
        }
    }
}
