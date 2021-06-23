import BlocksModels
import os


final class ToolbarBlockActionHandler {
    private let service: BlockActionServiceProtocol
    private var indexWalker: LinearIndexWalker?

    init(service: BlockActionServiceProtocol, indexWalker: LinearIndexWalker?) {
        self.service = service
        self.indexWalker = indexWalker
    }

func handlingToolbarAction(_ block: BlockActiveRecordModelProtocol, _ action: BlockToolbarAction) {
        switch action {
        case let .addBlock(blockType):
            switch blockType {
            case .objects(.page):
                service.createPage(afterBlock: block.blockModel.information)
            default:
                guard let newBlock = BlockBuilder.createInformation(block: block, action: action) else {
                    return
                }
                
                let shouldSetFocusOnUpdate = newBlock.content.isText ? true : false
                let position: BlockPosition = block.isTextAndEmpty ? .replace : .bottom
                
                service.add(newBlock: newBlock, targetBlockId: block.blockId, position: position, shouldSetFocusOnUpdate: shouldSetFocusOnUpdate)
            }
        case let .turnIntoBlock(value):
            // TODO: Add turn into
            switch value {
            case let .text(value): // Set Text Style
                let type: BlockContent
                switch value {
                case .text: type = .text(.empty())
                case .h1: type = .text(.init(contentType: .header))
                case .h2: type = .text(.init(contentType: .header2))
                case .h3: type = .text(.init(contentType: .header3))
                case .highlighted: type = .text(.init(contentType: .quote))
                }
                self.service.turnInto(block: block.blockModel.information, type: type, shouldSetFocusOnUpdate: false)

            case let .list(value): // Set Text Style
                let type: BlockContent
                switch value {
                case .bulleted: type = .text(.init(contentType: .bulleted))
                case .checkbox: type = .text(.init(contentType: .checkbox))
                case .numbered: type = .text(.init(contentType: .numbered))
                case .toggle: type = .text(.init(contentType: .toggle))
                }
                self.service.turnInto(block: block.blockModel.information, type: type, shouldSetFocusOnUpdate: false)

            case let .other(value): // Change divider style.
                let type: BlockContent
                switch value {
                case .lineDivider: type = .divider(.init(style: .line))
                case .dotsDivider: type = .divider(.init(style: .dots))
                case .code: return
                }
                self.service.turnInto(block: block.blockModel.information, type: type, shouldSetFocusOnUpdate: false)

            case .objects(.page):
                let type: BlockContent = .smartblock(.init(style: .page))
                self.service.turnInto(block: block.blockModel.information, type: type, shouldSetFocusOnUpdate: false)

            default:
                assertionFailure("TurnInto for that style is not implemented \(String(describing: action))")
            }
        }
    }
}
