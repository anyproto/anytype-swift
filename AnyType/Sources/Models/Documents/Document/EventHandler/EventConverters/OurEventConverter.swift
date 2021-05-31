import BlocksModels

final class OurEventConverter {
    private weak var container: ContainerModelProtocol?
    
    init(container: ContainerModelProtocol?) {
        self.container = container
    }
    
    func convert(_ event: OurEvent) -> EventHandlerUpdate? {
        switch event {
        case let .setFocus(focus):
            let blockId = focus.blockId
            guard var model = self.container?.blocksContainer.choose(by: blockId) else {
                assertionFailure("setFocus. We can't find model by id \(blockId)")
                return nil
            }
            model.isFirstResponder = true
            model.focusAt = focus.position
            
            /// TODO: We should check that we don't have blocks in updated List.
            /// IF id is in updated list, we should delay of `.didChange` event before all items will be drawn.
            /// For example, it can be done by another case.
            /// This case will capture a completion ( this `didChange()` function ) and call it later.
            model.container?.userSession.didChange()
            
            return nil
        case .setText:
            return nil
            /// TODO:
            /// Remove when you are ready.
//            let blockId = value.payload.blockId
//            guard let model = self.container?.blocksContainer.choose(by: blockId) else {
//                let logger = Logging.createLogger(category: .eventProcessor)
//                os_log(.debug, log: logger, "setText. We can't find model by id %@", String(describing: blockId))
//                return nil
//            }
//
//            guard let attributedText = value.payload.attributedString else {
//                let logger = Logging.createLogger(category: .eventProcessor)
//                os_log(.debug, log: logger, "setText. Text.Payload.attributedString is not allowed to be nil. %@", String(describing: blockId))
//                return nil
//            }
            
//            self.updater?.update(entry: focusedModel.blockModel.information.id, update: { (value) in
//                switch value.information.content {
//                case let .text(oldValue):
//                    var newValue = oldValue
//                    newValue.attributedText = attributedText
//                    var value = value
//                    value.information.content = .text(newValue)
//                default: return
//                }
//            })
//            switch model.blockModel.information.content {
//            case let .text(value):
//                var blockModel = model.blockModel
//                var updatedValue = value
//                updatedValue.attributedText = attributedText
//                blockModel.information.content = .text(updatedValue)
//                model.didChange()
//            default: break
//            }
            
            // set text to our model.
//            return .general
        case let .setTextMerge(value):
            let blockId = value.blockId
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
