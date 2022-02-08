import BlocksModels

typealias BlockMapping = Dictionary<BlockId, BlockViewModelProtocol>

final class EditorMainItemModelsHolder {
    var items = [EditorItem]() {
        didSet {
            blocksMapping = Dictionary(uniqueKeysWithValues: items.compactMap { item in
                guard case let .block(blockViewModel) = item else { return nil }

                return (blockViewModel.blockId, blockViewModel)
            })
        }
    }

    var header: ObjectHeader?
    private var blocksMapping = BlockMapping()
}

// MARK: - Models searching
extension EditorMainItemModelsHolder {
    func findModel(
        beforeBlockId blockId: BlockId,
        skipFeaturedRelations: Bool = true
    ) -> BlockViewModelProtocol? {
        guard let modelIndex = items.firstIndex(blockId: blockId) else { return nil }

        let index = items.index(before: modelIndex)
        guard let model = items[safe: index] else {
            return nil
        }

        guard case let .block(block) = model else { return nil }
        if block.content.type == .featuredRelations && skipFeaturedRelations {
            return findModel(beforeBlockId: block.blockId)
        }

        return block
    }

    func contentProvider(for blockId: BlockId) -> BlockViewModelProtocol? {
        blocksMapping[blockId]
    }

    func contentProvider(for item: EditorItem) -> BlockViewModelProtocol?  {
        switch item {
        case .header, .system:
            return nil
        case .block(let blockViewModelProtocol):
            return contentProvider(for: blockViewModelProtocol.blockId)
        }
    }

    func blockViewModel(at index: Int) -> BlockViewModelProtocol? {
        if case let .block(viewModel) = items[safe: index] {
            return viewModel
        }

        return nil
    }
}

// MARK: - Difference
extension EditorMainItemModelsHolder {
    func difference(
        between newItems: [EditorItem]
    ) -> CollectionDifference<EditorItem> {
        if items.isEmpty { return .init([])! }

        return newItems.difference(from: items) { (rhs, lhs) in
            switch (rhs, lhs) {
            case let (.system(rhsSystem), .system(lhsSystem)):
                return rhsSystem.hashable == lhsSystem.hashable
            case let (.block(lhsBlock), .block(rhsBlock)):
                return lhsBlock.hashable == rhsBlock.hashable
            case let (.header(lhsHeader), .header(rhsHeader)):
                return lhsHeader == rhsHeader
            default:
                return false
            }
        }
    }

    func applyDifference(difference: CollectionDifference<EditorItem>) {
        if !difference.isEmpty, let result = items.applying(difference) {
            items = result
        }
    }
}


extension Array where Element == EditorItem {
    func firstIndex(blockId: BlockId) -> Int? {
        firstIndex { element in
            guard case let .block(block) = element else { return false }
            return block.blockId == blockId
        }
    }

    var firstFeatureRelationBlock: BlockViewModelProtocol? {
        let item = first { blockModel  in
            if case let .block(block) = blockModel, case .featuredRelations = block.content {
                return true
            }
            return false
        }                                                                                                                                              
    }
}
