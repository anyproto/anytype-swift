import BlocksModels
import ProtobufMessages
import AnytypeCore

final class LocalEventConverter {
    private let blocksContainer: InfoContainerProtocol
    private let blockValidator = BlockValidator()
    
    init(blocksContainer: InfoContainerProtocol) {
        self.blocksContainer = blocksContainer
    }
    
    func convert(_ event: LocalEvent) -> EventsListenerUpdate? {
        switch event {
        case .setToggled, .documentClosed:
            return .general
        case let .setText(blockId: blockId, text: text):
            return blockSetTextUpdate(blockId: blockId, text: text)
        case .setLoadingState(blockId: let blockId):
            guard var info = blocksContainer.get(id: blockId) else {
                anytypeAssertionFailure("setLoadingState. Can't find model by id \(blockId)", domain: .localEventConverter)
                return nil
            }
            guard case var .file(content) = info.content else {
                anytypeAssertionFailure("Not file content of block \(blockId) for setLoading action", domain: .localEventConverter)
                return nil
            }
            
            content.state = .uploading
            info.content = .file(content)
            blocksContainer.add(info)
            return .blocks(blockIds: [blockId])
        case .reload(blockId: let blockId):
            return .blocks(blockIds: [blockId])
        }
    }
    
    // simplified version of inner converter method
    // func blockSetTextUpdate(_ newData: Anytype_Event.Block.Set.Text)
    // only text is changed
    private func blockSetTextUpdate(blockId: BlockId, text: MiddlewareString) -> EventsListenerUpdate {
        guard var info = blocksContainer.get(id: blockId) else {
            anytypeAssertionFailure("Block model with id \(blockId) not found in container", domain: .localEventConverter)
            return .general
        }
        guard case let .text(oldText) = info.content else {
            anytypeAssertionFailure("Block model doesn't support text:\n \(info)", domain: .localEventConverter)
            return .general
        }
        
        let middleContent = Anytype_Model_Block.Content.Text(
            text: text.text,
            style: oldText.contentType.asMiddleware,
            marks: text.marks,
            checked: oldText.checked,
            color: oldText.color?.rawValue ?? "",
            iconEmoji: oldText.iconEmoji,
            iconImage: oldText.iconImage
        )
        
        guard var textContent = middleContent.textContent else {
            anytypeAssertionFailure("We cannot block content from: \(middleContent)", domain: .localEventConverter)
            return .general
        }

        textContent.contentType = oldText.contentType
        textContent.number = oldText.number
        
        info.content = .text(textContent)
        info = blockValidator.validated(information: info)
        blocksContainer.add(info)
        
        return .blocks(blockIds: [blockId])
    }
}
