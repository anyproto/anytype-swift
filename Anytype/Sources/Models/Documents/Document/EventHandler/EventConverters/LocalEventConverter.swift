import BlocksModels
import ProtobufMessages

final class LocalEventConverter {
    private weak var container: ContainerModelProtocol?
    private let blockValidator = BlockValidator(restrictionsFactory: BlockRestrictionsFactory())
    
    init(container: ContainerModelProtocol?) {
        self.container = container
    }
    
    func convert(_ event: LocalEvent) -> EventHandlerUpdate? {
        switch event {
        case let .setFocus(blockId, position):
            setFocus(blockId: blockId, position: position)
            return nil
        case let .setTextMerge(blockId):
            guard let model = self.container?.blocksContainer.choose(by: blockId) else {
                assertionFailure("setTextMerge. We can't find model by id \(blockId)")
                return nil
            }
            
            /// We should call didChange publisher to invoke related setText event (`didChangePublisher()` subscription) in viewModel.
            
            model.didChange()
            
            return .general
        case .setToggled:
            return .general
        case let .setText(blockId: blockId, text: text):
            return blockSetTextUpdate(blockId: blockId, text: text)
        }
    }
    
    // simplified version of inner converter method
    // func blockSetTextUpdate(_ newData: Anytype_Event.Block.Set.Text)
    // only text is changed
    private func blockSetTextUpdate(blockId: BlockId, text: String) -> EventHandlerUpdate {
        typealias TextConverter = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter
        
        guard var blockModel = container?.blocksContainer.get(by: blockId) else {
            assertionFailure("Block model with id \(blockId) not found in container")
            return .general
        }
        guard case let .text(oldText) = blockModel.information.content else {
            assertionFailure("Block model doesn't support text:\n \(blockModel.information)")
            return .general
        }
        
        let middleContent = Anytype_Model_Block.Content.Text(
            text: text,
            style: BlockTextContentTypeConverter.asMiddleware(oldText.contentType),
            marks: TextConverter.asMiddleware(attributedText: oldText.attributedText).marks,
            checked: oldText.checked,
            color: oldText.color?.rawValue ?? ""
        )
        
        guard var textContent = ContentTextConverter().textContent(middleContent) else {
            assertionFailure("We cannot block content from: \(middleContent)")
            return .general
        }

        textContent.contentType = oldText.contentType
        textContent.number = oldText.number
        
        blockModel.information.content = .text(textContent)
        blockModel.information = blockValidator.validated(information: blockModel.information)
        
        return .update(.init(updatedIds: [blockId]))
    }
    
    private func setFocus(blockId: BlockId, position: BlockFocusPosition) {
        guard var model = container?.blocksContainer.choose(by: blockId) else {
            assertionFailure("setFocus. We can't find model by id \(blockId)")
            return
        }
        model.isFirstResponder = true
        model.focusAt = position
    }
}
