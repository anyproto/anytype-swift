import BlocksModels

struct BlockBuilder {
    typealias KeyboardAction = CustomTextView.UserAction.KeyboardAction

    static func createInformation(block: BlockModelProtocol, action: KeyboardAction, textPayload: String) -> BlockInformation? {
        switch block.information.content {
        case .text:
            return createContentType(block: block, action: action, textPayload: textPayload).flatMap { content in
                BlockInformation.createNew(content: content)
            }
        default: return nil
        }
    }

    static func createNewBlock(type: BlockContentType) -> BlockInformation? {
        createContentType(blockType: type).flatMap { content in
            var block = BlockInformation.createNew(content: content)
            
            guard
                case .file(let blockFile) = content,
                case .image = blockFile.contentType
            else { return block }
            
            block.alignment = .center

            return block
        }
    }
    
    static func createDefaultInformation() -> BlockInformation {
        return BlockInformation.createNew(content: .text(.empty()))
    }

    static func createDefaultInformation(block: BlockModelProtocol) -> BlockInformation? {
        switch block.information.content {
        case let .text(value):
            switch value.contentType {
            case .toggle: return BlockInformation.createNew(content: .text(.empty()))
            default: return nil
            }
        case .smartblock: return BlockInformation.createNew(content: .text(.empty()))
        default: return nil
        }
    }

    static func createContentType(
        block: BlockModelProtocol, action: KeyboardAction, textPayload: String
    ) -> BlockContent? {
        switch block.information.content {
        case let .text(blockType):
            switch blockType.contentType {
            case .bulleted where blockType.text != "": return .text(.init(contentType: .bulleted))
            case .checkbox where blockType.text != "": return .text(.init(contentType: .checkbox))
            case .numbered where blockType.text != "": return .text(.init(contentType: .numbered))
            case .toggle where block.isToggled: return .text(.init(contentType: .text))
            case .toggle where blockType.text != "": return .text(.init(contentType: .toggle))
            default: return .text(.init(contentType: .text))
            }
        default: return nil
        }
    }

    private static func createContentType(blockType: BlockContentType) -> BlockContent? {
        switch blockType {
        case let .text(style):
            return .text(.init(contentType: style))
        case .bookmark:
            return .bookmark(.empty())
        case let .divider(style):
            return .divider(.init(style: style))
        case let .file(type):
            return .file(.empty(contentType: type))
        case let .link(style):
            return .link(.init(style: style))
        case .layout, .smartblock:
            return nil
        }
    }
}
