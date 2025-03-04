import Services
import ProtobufMessages
import AnytypeCore

final class LocalEventConverter {
    private let infoContainer: any InfoContainerProtocol
    private let blockValidator = BlockValidator()
    
    init(infoContainer: some InfoContainerProtocol) {
        self.infoContainer = infoContainer
    }
    
    func convert(_ event: LocalEvent) -> [DocumentUpdate] {
        switch event {
        case .general:
            return [.general]
        case let .setToggled(blockId):
            // block - update state in toggle block if it is empty
            // general - update list of blocks if toggle block contains children
            return [.block(blockId: blockId), .general]
        case let .setStyle(blockId):
            return [.block(blockId: blockId)]
        case let .setText(blockId: blockId, text: text):
            return [blockSetTextUpdate(blockId: blockId, text: text)]
        case .setLoadingState(blockId: let blockId):
            guard var info = infoContainer.get(id: blockId) else {
                anytypeAssertionFailure("setLoadingState. Can't find model", info: ["blockId": "\(blockId)"])
                return []
            }
            guard case var .file(content) = info.content else {
                anytypeAssertionFailure("Not file content of block for setLoading action", info: ["blockId": "\(blockId)"])
                return []
            }
            
            content.state = .uploading
            info = info.updated(content: .file(content))
            infoContainer.add(info)
            return [.block(blockId: blockId)]
        case .reload(blockId: let blockId):
            return [.block(blockId: blockId)]
        }
    }
        
    // simplified version of inner converter method
    // func blockSetTextUpdate(_ newData: Anytype_Event.Block.Set.Text)
    // only text is changed
    private func blockSetTextUpdate(blockId: String, text: MiddlewareString) -> DocumentUpdate {
        guard var info = infoContainer.get(id: blockId) else {
            anytypeAssertionFailure("Block model not found in container", info: ["blockId": "\(blockId)"])
            return .unhandled(blockId: blockId)
        }
        guard case let .text(oldText) = info.content else {
            anytypeAssertionFailure("Block model doesn't support text", info: ["contentType": "\(info.content.type)"])
            return .unhandled(blockId: blockId)
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
            anytypeAssertionFailure("We cannot block content")
            return .unhandled(blockId: blockId)
        }

        textContent.contentType = oldText.contentType
        textContent.number = oldText.number
        
        info = info.updated(content: .text(textContent))
        info = blockValidator.validated(information: info)
        infoContainer.add(info)
        
        return .unhandled(blockId: blockId)
    }
}
