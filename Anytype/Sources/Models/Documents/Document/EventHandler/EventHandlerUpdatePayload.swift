//import BlocksModels
//
//final class EventHandlerUpdatePayload {
//    
//    let updatedIds: Set<BlockId>
//    
//    var hasUpdates: Bool {
//        !updatedIds.isEmpty
//    }
//    
//    init(updatedIds: Set<BlockId> = Set()) {
//        self.updatedIds = updatedIds
//    }
//    
//    static func merged(
//        lhs: EventHandlerUpdatePayload,
//        rhs: EventHandlerUpdatePayload
//    ) -> EventHandlerUpdatePayload {
//        return EventHandlerUpdatePayload(updatedIds: lhs.updatedIds.union(rhs.updatedIds))
//    }
//}
