import Foundation
import os

public struct TreeBlockBuilder {
    private var builder: BlockBuilderProtocol

    public static var defaultValue: Self = {
        .init(builder: TopLevelBuilderImpl.blockBuilder)
    }()

    public init(builder: BlockBuilderProtocol) {
        self.builder = builder
    }

    // Description
    //
    // Steps
    // 1. create dictionary: ID -> Model
    // 2. check if we have only one root
    // 3. If we have several roots, so, notify about it.
    // 4. find root id as first element in roots. No matter, how much roots we have.
    // 5. Build tree.
    // Note
    //
    // 6 is necessary
    //
    // Observation
    //
    // Consider unsorted (not sorted topologically) blocks.
    // At the end we _may_ don't know if these blocks have correct indices or not.
    // For that case we _should_ rerun building indices in second time after we determine root.
    private func fromList(information: [Block.Information.InformationModel], isRoot: (BlockModelProtocol) -> Bool) -> BlockContainerModelProtocol {
        fromList(information.compactMap(self.builder.createBlockModel), isRoot: isRoot)
    }

    private func fromList(_ models: [BlockModelProtocol], isRoot: (BlockModelProtocol) -> Bool) -> BlockContainerModelProtocol {
        // 1. create dictionary: ID -> Model
        var container = self.builder.build(list: models)

        // 2. check if we have only one root
        let roots = models.filter(isRoot)

        guard roots.count != 0 else {
            assertionFailure("Unknown situation. We can't have zero roots.")
            return self.builder.emptyContainer()
        }

        // 3. If we have several roots, so, notify about it.
        if roots.count != 1 {
            // this situation is not possible, but, let handle it.
            assertionFailure("We have several roots for our rootId. Not possible, but let us handle it.")
        }

        // 4. find root id as first element in roots. No matter, how much roots we have.
        // But for now we don't need root id in this container.
        let rootId = roots[0].information.id
        container.rootId = rootId

        // 5. Build tree.
        self.builder.buildTree(container: container, rootId: rootId)

        return container
    }

    /// Build blocks tree from middleware model
    /// - Parameters:
    ///   - information: block information model array from which we build tree
    ///   - rootId: block root id (target rootId)
    /// - Returns: Container that represents the tree of blocks
    public func buildBlocksTree(from information: [Block.Information.InformationModel], with rootId: BlockId) -> BlockContainerModelProtocol {
        fromList(information: information, isRoot: { $0.information.id == rootId })
    }
}

// MARK: - ToList

struct FromTreeToListTransformer {
    private func toListRecursively(_ block: BlockActiveRecordModelProtocol) -> [BlockActiveRecordModelProtocol] {
        var result: [BlockActiveRecordModelProtocol] = []
        result.append(contentsOf: block.childrenIds().map(block.findChild(by:)).compactMap({$0}))
        return result
    }

    public func toList(_ model: BlockActiveRecordModelProtocol) -> [BlockActiveRecordModelProtocol] {
        self.toListRecursively(model)
    }
}
