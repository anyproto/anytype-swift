
import BlocksModels

struct BlockChildrenIdsUpdates {
    
    let added: [EventHandlerUpdateChange]
    let deleted: [BlockId]
    let moved: [EventHandlerUpdateChange]
}
