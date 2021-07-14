import BlocksModels

struct BlockBuilder {
    typealias KeyboardAction = CustomTextView.UserAction.KeyboardAction

    static func createInformation(block: BlockActiveRecordProtocol, action: KeyboardAction, textPayload: String) -> BlockInformation? {
        switch block.content {
        case .text:
            return createContentType(block: block, action: action, textPayload: textPayload).flatMap { content in
                BlockInformation.createNew(content: content)
            }
        default: return nil
        }
    }

    static func createInformation(blockType: BlockViewType) -> BlockInformation? {
        return createContentType(blockType: blockType).flatMap { content in
            BlockInformation.createNew(content: content)
        }
    }
    
    static func createDefaultInformation() -> BlockInformation {
        return BlockInformation.createNew(content: .text(.empty()))
    }

    static func createDefaultInformation(block: BlockActiveRecordProtocol) -> BlockInformation? {
        switch block.content {
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
        block: BlockActiveRecordProtocol, action: KeyboardAction, textPayload: String
    ) -> BlockContent? {
        switch block.content {
        case let .text(blockType):
            switch blockType.contentType {
            case .bulleted where blockType.attributedText.string != "": return .text(.init(contentType: .bulleted))
            case .checkbox where blockType.attributedText.string != "": return .text(.init(contentType: .checkbox))
            case .numbered where blockType.attributedText.string != "": return .text(.init(contentType: .numbered))
            case .toggle where block.isToggled: return .text(.init(contentType: .text))
            case .toggle where blockType.attributedText.string != "": return .text(.init(contentType: .toggle))
            default: return .text(.init(contentType: .text))
            }
        default: return nil
        }
    }

    private static func createContentType(blockType: BlockViewType) -> BlockContent? {
        switch blockType {
        case let .text(value):
            switch value {
            case .text: return .text(.init(contentType: .text))
            case .h1: return .text(.init(contentType: .header))
            case .h2: return .text(.init(contentType: .header2))
            case .h3: return .text(.init(contentType: .header3))
            case .highlighted: return .text(.init(contentType: .quote))
            }
        case let .list(value):
            switch value {
            case .bulleted: return .text(.init(contentType: .bulleted))
            case .checkbox: return .text(.init(contentType: .checkbox))
            case .numbered: return .text(.init(contentType: .numbered))
            case .toggle: return .text(.init(contentType: .toggle))
            }
        case let .objects(mediaType):
            switch mediaType {
            case .page: return .link(.init(style: .page))
            case .picture: return .file(.empty(contentType: .image))
            case .bookmark: return .bookmark(.empty())
            case .file: return .file(.empty(contentType: .file))
            case .video: return .file(.empty(contentType: .video))
            case .linkToObject: return nil
            }
        case let .other(value):
            switch value {
            case .lineDivider: return .divider(.init(style: .line))
            case .dotsDivider: return .divider(.init(style: .dots))
            case .code: return .text(BlockText(contentType: .code))
            }
        case .tool(_):
            return nil
        }
    }
}
