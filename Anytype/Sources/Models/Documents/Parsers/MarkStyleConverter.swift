import BlocksModels
import ProtobufMessages
import AnytypeCore

enum MarkStyleActionConverter {
    
    static func asModel(tuple: MiddlewareTuple, detailsStorage: ObjectDetailsStorageProtocol) -> MarkupType? {
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
            return .link(URL(string: tuple.value))

        case .textColor:
            guard let color = MiddlewareColor(rawValue: tuple.value)?.color(background: false) else {
                return nil
            }
            return .textColor(color)

        case .backgroundColor:
            guard let color = MiddlewareColor(rawValue: tuple.value)?.color(background: true) else {
                return nil
            }
            return .backgroundColor(color)

        case .mention:
            guard let details = detailsStorage.get(id: tuple.value) else {
                return .mention(.noDetails(blockId: tuple.value))
            }
            return .mention(MentionData(details: details))

        case .object:
            return .linkToObject(tuple.value)

        case .emoji:
            anytypeAssertionFailure("Unrecognized markup emoji")
            return nil

        case .UNRECOGNIZED(let value):
            anytypeAssertionFailure("Unrecognized markup \(value)")
            return nil
        }
    }
}
