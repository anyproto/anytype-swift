import BlocksModels


final class ButtonBlockActionHandler {
    private let service: BlockActionServiceProtocol

    init(service: BlockActionServiceProtocol) {
        self.service = service
    }

    func handlingButtonViewAction(_ block: BlockActiveRecordModelProtocol, _ action: ActionPayload.ButtonAction) {
        switch action {
        case .toggle(.toggled):
            self.service.receiveOurEvents([.setToggled(blockId: block.blockId)])
        case .toggle(.insertFirst):
            if let defaultBlock = BlockBuilder.createDefaultInformation(block: block) {
                self.service.addChild(childBlock: defaultBlock, parentBlockId: block.blockId)
            }
        case let .checkbox(value):
            service.checked(block: block, newValue: value)
        }
    }
}
