import BlocksModels

final class UserActionHandler {
    private let service: BlockActionServiceProtocol

    init(service: BlockActionServiceProtocol) {
        self.service = service
    }

    func handlingUserAction(_ block: BlockActiveRecordModelProtocol, _ action: BlocksViews.UserAction) {
        switch action {
        case let .specific(.file(.shouldUploadFile(value))):
            service.upload(block: block.blockModel.information, filePath: value.filePath)
        default: return
        }
    }
}
