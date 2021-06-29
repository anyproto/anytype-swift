import BlocksModels

extension DocumentEditorViewModel: EditorModuleSelectionHandlerHolderProtocol {
    func selectAll() {
        let ids = modelsHolder.models.dropFirst().reduce(into: [BlockId: BlockContentType]()) { result, model in
            result[model.blockId] = model.block.content.type
        }
        selectionHandler.select(ids: ids)
    }
}
