import Services
import AnytypeCore

typealias BlockMapping = Dictionary<BlockId, BlockViewModelProtocol>

final class EditorMainItemModelsHolder {
    var items = [EditorItem]() {
        didSet {
            let dictionary = items.reduce(into: BlockMapping(), { result, pair in
                guard case let .block(blockViewModel) = pair else { return }
                
                if let viewModel = result[blockViewModel.blockId] {
                    anytypeAssertionFailure("There are duplicates with block type: \(viewModel.content.type)")
                }
                
                result[blockViewModel.blockId] = blockViewModel
            })
            
            blocksMapping = dictionary
        }
    }

    var header: ObjectHeader?
    private var blocksMapping = BlockMapping()
}

// MARK: - Models searching
extension EditorMainItemModelsHolder {
    func findModel(
        beforeBlockId blockId: BlockId,
        acceptingTypes: [BlockContentType]
    ) -> BlockViewModelProtocol? {
        guard let modelIndex = items.firstIndex(blockId: blockId) else { return nil }

        let index = items.index(before: modelIndex)

        guard items.indices.contains(index) else { return nil }

        let model = items[0...index].last { item in
            if case .block = item { return true }

            return false
        }

        guard case let .block(block) = model else { return nil }

        if !acceptingTypes.contains(block.content.type) {
            return findModel(beforeBlockId: block.blockId, acceptingTypes: acceptingTypes)
        }

        return block
    }

    func contentProvider(for blockId: BlockId) -> BlockViewModelProtocol? {
        blocksMapping[blockId]
    }

    func contentProvider(for item: EditorItem) -> EditorItem?  {
        switch item {
        case .header, .system:
            return nil
        case .block(let blockViewModelProtocol):
            return contentProvider(for: blockViewModelProtocol.blockId)
                .map { EditorItem.block($0) }
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

    var allRelationViewModel: [BlockViewModelProtocol] {
        compactMap { element -> BlockViewModelProtocol? in
            if case let .block(block) = element {
                switch block.content {
                case .featuredRelations, .relation:
                    return block
                default:
                    return nil
                }
            }
            return nil
        }
    }
}
