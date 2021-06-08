import BlocksModels

protocol DocumentViewInteraction: AnyObject {
    /// Update blocks by ids
    /// - Parameter ids: blocks ids
    func updateBlocks(with ids: Set<BlockId>)
}
