import BlocksModels

struct BlockBuilder {
    static func createInformation(info: BlockInformation) -> BlockInformation? {
        switch info.content {
        case .text:
            return createContentType(info: info).flatMap { content in
                BlockInformation(content: content)
            }
        default: return nil
        }
    }
    
    static func createNewLink(targetBlockId: BlockId) -> BlockInformation {
        BlockInformation(
            content: .link(
                BlockLink(targetBlockID: targetBlockId, style: .page, fields: [:])
            )
        )
    }

    static func createNewBlock(type: BlockContentType) -> BlockInformation? {
        createContentType(blockType: type).flatMap { content in
            var block = BlockInformation(content: content)
            
            if case .file(let blockFile) = content, case .image = blockFile.contentType {
                block.alignment = .center
            }

            return block
        }
    }

    static func textStyle(info: BlockInformation) -> BlockText.Style? {
        if case let .text(textContent) = createContentType(info: info) {
            return textContent.contentType
        }
        
        return nil
    }

    private static func createContentType(info: BlockInformation) -> BlockContent? {
        switch info.content {
        case let .text(blockType):
            switch blockType.contentType {
            case .bulleted where blockType.text != "": return .text(.init(contentType: .bulleted))
            case .checkbox where blockType.text != "": return .text(.init(contentType: .checkbox))
            case .numbered where blockType.text != "": return .text(.init(contentType: .numbered))
            case .toggle where UserSession.shared.isToggled(blockId: info.id) : return .text(.init(contentType: .text))
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
        case let .relation(key: key):
            return .relation(.init(key: key))
        case .layout, .smartblock, .featuredRelations, .dataView:
            return nil
        }
    }
}
