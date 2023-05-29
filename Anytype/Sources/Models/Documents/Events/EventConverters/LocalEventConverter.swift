import Services
import ProtobufMessages
import AnytypeCore

final class LocalEventConverter {
    private let infoContainer: InfoContainerProtocol
    private let blockValidator = BlockValidator()
    
    init(infoContainer: InfoContainerProtocol) {
        self.infoContainer = infoContainer
    }
    
    func convert(_ event: LocalEvent) -> DocumentUpdate? {
        switch event {
        case .setToggled, .setStyle, .general:
            return .general
        case let .setText(blockId: blockId, text: text):
            return blockSetTextUpdate(blockId: blockId, text: text)
        case .setLoadingState(blockId: let blockId):
            guard var info = infoContainer.get(id: blockId) else {
                anytypeAssertionFailure("setLoadingState. Can't find model by id \(blockId)")
                return nil
            }
            guard case var .file(content) = info.content else {
                anytypeAssertionFailure("Not file content of block \(blockId) for setLoading action")
                return nil
            }
            
            content.state = .uploading
            info = info.updated(content: .file(content))
            infoContainer.add(info)
            return .blocks(blockIds: [blockId])
        case .reload(blockId: let blockId):
            return .blocks(blockIds: [blockId])
        case .header(let data):
            return .header(data)
        }
    }
        
    // simplified version of inner converter method
    // func blockSetTextUpdate(_ newData: Anytype_Event.Block.Set.Text)
    // only text is changed
    private func blockSetTextUpdate(blockId: BlockId, text: MiddlewareString) -> DocumentUpdate {
        guard var info = infoContainer.get(id: blockId) else {
            anytypeAssertionFailure("Block model with id \(blockId) not found in container")
            return .general
        }
        guard case let .text(oldText) = info.content else {
            anytypeAssertionFailure("Block model doesn't support text:\n \(info)")
            return .general
        }
        
        let middleContent = Anytype_Model_Block.Content.Text.with {
            $0.text = text.text
            $0.style = oldText.contentType.asMiddleware
            $0.marks = text.marks
            $0.checked = oldText.checked
            $0.color = oldText.color?.rawValue ?? ""
            $0.iconEmoji = oldText.iconEmoji
            $0.iconImage = oldText.iconImage
        }
        
        guard var textContent = middleContent.textContent else {
            anytypeAssertionFailure("We cannot block content from: \(middleContent)")
            return .general
        }

        textContent.contentType = oldText.contentType
        textContent.number = oldText.number
        
        info = info.updated(content: .text(textContent))
        info = blockValidator.validated(information: info)
        infoContainer.add(info)
        
        return .blocks(blockIds: [blockId])
    }
}
