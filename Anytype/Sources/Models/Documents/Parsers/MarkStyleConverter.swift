import BlocksModels
import ProtobufMessages
import AnytypeCore

enum MarkStyleConverter {
    
    static func asModel(_ tuple: MiddlewareTuple) -> MarkStyle? {
        switch tuple.attribute {
        case .strikethrough:
            return .strikethrough(true)
        case .keyboard:
            return .keyboard(true)
        case .italic:
            return .italic(true)
        case .bold:
            return .bold(true)
        case .underscored:
            return .underscored(true)
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
            return .mention(tuple.value)
        case .UNRECOGNIZED:
            anytypeAssertionFailure("Unrecognized markup")
            return nil
        }
    }

    static func asMiddleware(_ style: MarkStyle) -> MiddlewareTuple? {
        switch style {
        case .bold:
            return MiddlewareTuple(attribute: .bold, value: "")
        case .italic:
            return MiddlewareTuple(attribute: .italic, value: "")
        case .keyboard:
            return MiddlewareTuple(attribute: .keyboard, value: "")
        case .strikethrough:
            return MiddlewareTuple(attribute: .strikethrough, value: "")
        case .underscored:
            return MiddlewareTuple(attribute: .underscored, value: "")
            
        case let .textColor(color):
            guard let color = color?.middlewareString(background: false) else {
                return nil
            }
            return MiddlewareTuple(attribute: .textColor, value: color)
            
        case let .backgroundColor(color):
            guard let color = color?.middlewareString(background: true) else {
                return nil
            }
            return MiddlewareTuple(attribute: .backgroundColor, value: color)
            
        case let .link(value):
            return MiddlewareTuple(attribute: .link, value: value?.absoluteString ?? "")
            
        case let .mention(pageId):
            guard let pageId = pageId else { return nil }
            return MiddlewareTuple(attribute: .mention, value: pageId)
        }
    }
}
