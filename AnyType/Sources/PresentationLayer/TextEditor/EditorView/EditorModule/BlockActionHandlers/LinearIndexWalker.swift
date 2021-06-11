import BlocksModels

final class LinearIndexWalker {
    private weak var viewModel: DocumentEditorViewModel?

    init(_ model: DocumentEditorViewModel) {
        self.viewModel = model
    }
}

// MARK: Search
extension LinearIndexWalker {
    func model(
        beforeModel model: BlockActiveRecordModelProtocol,
        includeParent: Bool,
        onlyFocused: Bool = true
    ) -> BlockActiveRecordModelProtocol? {
        guard let viewModel = viewModel else {
            return nil
        }
        
        let models = viewModel.blocksViewModels.compactMap { $0.block }
        /// Do we actually need parent?
        guard let modelIndex = models.firstIndex(where: { $0.blockId == model.blockId }) else { return nil }

        /// Iterate back
        /// Actually, `index(before:)` doesn't respect indices of collection.
        /// Consider
        ///
        /// let a: [Int] = []
        /// a.startIndex // 0
        /// a.index(before: a.startIndex) // -1
        ///
        let index = models.index(before: modelIndex)
        let startIndex = models.startIndex
        
        /// TODO:
        /// Look at documentation how we should handle different blocks types.
        if index >= startIndex {
            let object = models[index]
            switch object.content {
            case .text: return object
            default: return nil
            }
        }

        return nil
    }
}
