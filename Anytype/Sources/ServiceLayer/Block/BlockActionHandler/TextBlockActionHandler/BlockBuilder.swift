import BlocksModels
import AnytypeCore
import SwiftUI

struct BlockBuilder {    
    static func createNewPageLink(targetBlockId: BlockId) -> BlockInformation {
        let content: BlockContent = .link(BlockLink(targetBlockID: targetBlockId, style: .page, fields: [:]))
        return BlockInformation.empty(content: content)
    }
    
    static func createNewBlock(type: BlockContentType) -> BlockInformation? {
        createContent(type: type).flatMap { content in
            var block = BlockInformation.empty(content: content)
            
            if case .file(let blockFile) = content, case .image = blockFile.contentType {
                block = block.updated(with: LayoutAlignment.center)
            }

            return block
        }
    }

    private static func createContent(type: BlockContentType) -> BlockContent? {
        switch type {
        case let .text(style):
            return .text(.empty(contentType: style))
        case .bookmark:
            return .bookmark(.empty())
        case let .divider(style):
            return .divider(.init(style: style))
        case let .file(type):
            return .file(.empty(contentType: type))
        case let .link(style):
            return .link(.empty(style: style))
        case let .relation(key: key):
            return .relation(.init(key: key))
        case .layout, .smartblock, .featuredRelations, .dataView:
            anytypeAssertionFailure("Unsupported type \(type)", domain: .blockBuilder)
            return nil
        }
    }
    
    private static func createContent(info: BlockInformation) -> BlockContent? {
        switch info.content {
        case let .text(blockType):
            switch blockType.contentType {
            case .bulleted where blockType.text != "": return .text(.empty(contentType: .bulleted))
            case .checkbox where blockType.text != "": return .text(.empty(contentType: .checkbox))
            case .numbered where blockType.text != "": return .text(.empty(contentType: .numbered))
            case .toggle where ToggleStorage.shared.isToggled(blockId: info.id) : return .text(.empty(contentType: .text))
            case .toggle where blockType.text != "": return .text(.empty(contentType: .toggle))
            default: return .text(.empty(contentType: .text))
            }
        default: return nil
        }
    }
}
