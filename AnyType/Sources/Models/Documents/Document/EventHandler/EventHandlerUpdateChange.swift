import BlocksModels

/// Entity with change information which block should be inserted/moved after defined block
struct EventHandlerUpdateChange: Hashable {
    
    /// Block id to insert/move
    let targetBlockId: BlockId
    
    /// Block id after which to insert/move target block
    let afterBlockId: BlockId
}
