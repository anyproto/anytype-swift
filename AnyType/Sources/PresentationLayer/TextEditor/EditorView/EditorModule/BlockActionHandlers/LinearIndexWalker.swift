import BlocksModels

final class LinearIndexWalker {
    private var models: [BlockActiveRecordModelProtocol] = []
    private var defaultModels: [BlockActiveRecordModelProtocol]

    init(_ model: DocumentEditorViewModel) {
        defaultModels = model.blocksViewModels.compactMap { $0.block }
    }

    func renew() {
        models = defaultModels
    }
}

// MARK: Search
extension LinearIndexWalker {
    func model(beforeModel model: BlockActiveRecordModelProtocol, includeParent: Bool, onlyFocused: Bool = true) -> BlockActiveRecordModelProtocol? {
        /// Do we actually need parent?
        guard let modelIndex = self.models.firstIndex(where: { $0.blockId == model.blockId }) else { return nil }

        /// Iterate back
        /// Actually, `index(before:)` doesn't respect indices of collection.
        /// Consider
        ///
        /// let a: [Int] = []
        /// a.startIndex // 0
        /// a.index(before: a.startIndex) // -1
        ///
        let index = self.models.index(before: modelIndex)
        let startIndex = self.models.startIndex
        
        /// TODO:
        /// Look at documentation how we should handle different blocks types.
        if index >= startIndex {
            let object = self.models[index]
            switch object.content {
            case .text: return object
            default: return nil
            }
        }

        return nil
    }
}
