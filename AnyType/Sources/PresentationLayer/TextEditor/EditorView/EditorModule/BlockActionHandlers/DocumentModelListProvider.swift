import BlocksModels

protocol UserInteractionHandlerListModelsProvider {
    var getModels: [BlockActiveRecordModelProtocol] {get}
}

struct DocumentModelListProvider: UserInteractionHandlerListModelsProvider {
    private weak var model: DocumentEditorViewModel?
    private var _models: [BlockActiveRecordModelProtocol] = [] // Do we need cache?

    init(model: DocumentEditorViewModel) {
        self.model = model
    }

    var getModels: [BlockActiveRecordModelProtocol] {
        self.model?.blocksViewModels.compactMap { $0.block } ?? []
    }
}
