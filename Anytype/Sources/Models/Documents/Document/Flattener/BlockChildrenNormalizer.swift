
import BlocksModels

/// Normalizer can fix blocks content after block models have been changed
protocol BlockChildrenNormalizer {
    
    /// Normalize content of children with ids
    ///
    /// - Parameters:
    ///   - ids: Children ids to change
    ///   - container: Container with all blocks
    func normalize(_ ids: [BlockId], in blocksContainer: BlockContainerModelProtocol)
}
