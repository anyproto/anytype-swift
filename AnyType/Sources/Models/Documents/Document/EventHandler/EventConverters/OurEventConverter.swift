import BlocksModels

final class OurEventConverter {
    private weak var container: ContainerModelProtocol?
    
    init(container: ContainerModelProtocol?) {
        self.container = container
    }
    
    func convert(_ event: OurEvent) -> EventHandlerUpdate? {
        switch event {
        case let .setFocus(blockId, position):
            guard var model = container?.blocksContainer.choose(by: blockId) else {
                assertionFailure("setFocus. We can't find model by id \(blockId)")
                return nil
            }
            model.isFirstResponder = true
            model.focusAt = position
            
            /// TODO: We should check that we don't have blocks in updated List.
            /// IF id is in updated list, we should delay of `.didChange` event before all items will be drawn.
            /// For example, it can be done by another case.
            /// This case will capture a completion ( this `didChange()` function ) and call it later.
            model.container?.userSession.didChange()
            
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
        }
    }
}
