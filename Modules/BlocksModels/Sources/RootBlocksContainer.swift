import Foundation


/// The main intention of this class is to store rootId and store all containers together.
/// As soon as we don't use rootId in `Block.Container`, it is safe to transfer it here.
final class RootBlocksContainer {
    private var _rootId: BlockId?
    private var _blocksContainer: BlockContainerModelProtocol = TopLevelBuilderImpl.blockBuilder.emptyContainer()
    private var _detailsContainer: DetailsStorageProtocol = TopLevelBuilderImpl.detailsBuilder.emptyStorage()
}

extension RootBlocksContainer: ContainerModel {
    var rootId: BlockId? {
        get {
            self._rootId
        }
        set {
            self._rootId = newValue
        }
    }
    var blocksContainer: BlockContainerModelProtocol {
        get {
            self._blocksContainer
        }
        set {
            self._blocksContainer = newValue
        }
    }
    var detailsContainer: DetailsStorageProtocol {
        get {
            self._detailsContainer
        }
        set {
            self._detailsContainer = newValue
        }
    }
}
