import BlocksModels
import ProtobufMessages
import AnytypeCore

final class LocalEventConverter {
    private let blocksContainer: BlockContainerModelProtocol
    private let blockValidator = BlockValidator()
    
    init(
        blocksContainer: BlockContainerModelProtocol
    ) {
        self.blocksContainer = blocksContainer
    }
    
    func convert(_ event: LocalEvent) -> EventsListenerUpdate? {
        switch event {
        case let .setFocus(blockId, position):
            setFocus(blockId: blockId, position: position)
            return .general // https://app.clickup.com/t/1r67hcc
//            return .blocks(blockIds: [blockId])
        case .setToggled, .documentClosed:
            return .general
        case let .setText(blockId: blockId, text: text):
            return blockSetTextUpdate(blockId: blockId, text: text)
        case .setLoadingState(blockId: let blockId):
            guard var model = blocksContainer.model(id: blockId) else {
                anytypeAssertionFailure("setLoadingState. Can't find model by id \(blockId)", domain: .localEventConverter)
                return nil
            }
            guard case var .file(content) = model.information.content else {
                anytypeAssertionFailure("Not file content of block \(blockId) for setLoading action", domain: .localEventConverter)
                return nil
            }
            
            content.state = .uploading
            model.information.content = .file(content)
            return .blocks(blockIds: [blockId])
        case .reload(blockId: let blockId):
            return .blocks(blockIds: [blockId])
        }
    }
    
    // simplified version of inner converter method
    // func blockSetTextUpdate(_ newData: Anytype_Event.Block.Set.Text)
    // only text is changed
    private func blockSetTextUpdate(blockId: BlockId, text: MiddlewareString) -> EventsListenerUpdate {
        guard var blockModel = blocksContainer.model(id: blockId) else {
            anytypeAssertionFailure("Block model with id \(blockId) not found in container", domain: .localEventConverter)
            return .general
        }
        guard case let .text(oldText) = blockModel.information.content else {
            anytypeAssertionFailure("Block model doesn't support text:\n \(blockModel.information)", domain: .localEventConverter)
            return .general
        }
        
        let middleContent = Anytype_Model_Block.Content.Text(
            text: text.text,
            style: oldText.contentType.asMiddleware,
            marks: text.marks,
            checked: oldText.checked,
            color: oldText.color?.rawValue ?? ""
        )
        
        guard var textContent = middleContent.textContent else {
            anytypeAssertionFailure("We cannot block content from: \(middleContent)", domain: .localEventConverter)
            return .general
        }

        textContent.contentType = oldText.contentType
        textContent.number = oldText.number
        
        blockModel.information.content = .text(textContent)
        blockModel.information = blockValidator.validated(information: blockModel.information)
        
        return .blocks(blockIds: [blockId])
    }
    
    private func setFocus(blockId: BlockId, position: BlockFocusPosition) {
        guard var model = blocksContainer.model(id: blockId) else {
            anytypeAssertionFailure("SetFocus: No model with id \(blockId)", domain: .localEventConverterSetFocus)
            return
        }
        model.isFirstResponder = true
        model.focusAt = position
    }
}
