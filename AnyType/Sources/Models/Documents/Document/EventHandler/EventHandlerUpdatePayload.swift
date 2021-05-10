
import BlocksModels

final class EventHandlerUpdatePayload {
    
    let addedIds: [EventHandlerUpdateChange]
    let deletedIds: Set<BlockId>
    let updatedIds: Set<BlockId>
    let movedIds: Set<EventHandlerUpdateChange>
    let openedToggleId: BlockId?
    
    var hasUpdates: Bool {
        !addedIds.isEmpty ||
        !deletedIds.isEmpty ||
        !updatedIds.isEmpty ||
        !movedIds.isEmpty ||
        openedToggleId != nil
    }
    
    init(addedIds: [EventHandlerUpdateChange] = [],
         deletedIds: Set<BlockId> = Set(),
         updatedIds: Set<BlockId> = Set(),
         movedIds: Set<EventHandlerUpdateChange> = Set(),
         openedToggleId: BlockId? = nil) {
        self.addedIds = addedIds
        self.deletedIds = deletedIds
        self.updatedIds = updatedIds
        self.movedIds = movedIds
        self.openedToggleId = openedToggleId
    }
    
    static func merged(lhs: EventHandlerUpdatePayload,
                       rhs: EventHandlerUpdatePayload) -> EventHandlerUpdatePayload {
        // Opening and closing toggle block is only local feature
        // so there might be either 1 or 0 opened toggle blocks
        let openedBlockId = lhs.openedToggleId ?? rhs.openedToggleId
        return EventHandlerUpdatePayload(addedIds: calculateAddedIds(lhs: lhs, rhs: rhs),
                                         deletedIds: calculateDeletedIds(lhs: lhs, rhs: rhs),
                                         updatedIds: lhs.updatedIds.union(rhs.updatedIds),
                                         movedIds: calulateMovedIds(lhs: lhs, rhs: rhs),
                                         openedToggleId: openedBlockId)
    }
    
    private static func calculateAddedIds(lhs: EventHandlerUpdatePayload,
                                          rhs: EventHandlerUpdatePayload) -> [EventHandlerUpdateChange] {
        // If one update has add block operation with id "111"
        // and another update has delete block operation with the same ("111") id
        // we must not return it in addedIds in final update
        // because there should be move operation
        
        let filteredLhsAddedIds: [EventHandlerUpdateChange]
        if rhs.deletedIds.isEmpty {
            filteredLhsAddedIds = lhs.addedIds
        } else {
            filteredLhsAddedIds = lhs.addedIds.filter { !rhs.deletedIds.contains($0.targetBlockId) }
        }
        
        let filteredRhsAddedIds: [EventHandlerUpdateChange]
        if lhs.deletedIds.isEmpty {
            filteredRhsAddedIds = rhs.addedIds
        } else {
            filteredRhsAddedIds = rhs.addedIds.filter { !lhs.deletedIds.contains($0.targetBlockId) }
        }
        
        return filteredLhsAddedIds + filteredRhsAddedIds
    }
    
    private static func calculateDeletedIds(lhs: EventHandlerUpdatePayload,
                                            rhs: EventHandlerUpdatePayload) -> Set<BlockId> {
        // If one update defines delete block operation with id "222"
        // and another update has add block operation with the same ("222") id
        // we must not return it in deletedIds in final update
        // because there should be move operation
        
        let rhsAddedIds = Set(rhs.addedIds.map(\.targetBlockId))
        let filteredLhsDeletedIds = lhs.deletedIds.subtracting(rhsAddedIds)
        
        let lhsAddedIds = Set(lhs.addedIds.map(\.targetBlockId))
        let filteredRhsDeletedIds = rhs.deletedIds.subtracting(lhsAddedIds)
        
        return filteredLhsDeletedIds.union(filteredRhsDeletedIds)
    }
    
    private static func calulateMovedIds(lhs: EventHandlerUpdatePayload,
                                         rhs: EventHandlerUpdatePayload) -> Set<EventHandlerUpdateChange> {
        // If one update contains addedIds with "111" block
        // and another update contains deletedIds with "111" block
        // that means no block delete or add - it is block move
        // from one parent to another or inside one parent
        var movesFromLhsAddedAndRhsDeleted = [EventHandlerUpdateChange]()
        if !lhs.addedIds.isEmpty && !rhs.deletedIds.isEmpty {
            movesFromLhsAddedAndRhsDeleted = lhs.addedIds.filter { rhs.deletedIds.contains($0.targetBlockId) }
        }
        var movesFromRhsAddedAndLhsDeleted = [EventHandlerUpdateChange]()
        if !rhs.addedIds.isEmpty && !lhs.deletedIds.isEmpty {
            movesFromRhsAddedAndLhsDeleted = rhs.addedIds.filter { lhs.deletedIds.contains($0.targetBlockId) }
        }
        return lhs.movedIds
            .union(movesFromLhsAddedAndRhsDeleted)
            .union(movesFromRhsAddedAndLhsDeleted)
            .union(rhs.movedIds)
    }
}
