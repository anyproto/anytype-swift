import BlocksModels
import AnytypeCore

extension Array where Element == EventHandlerUpdate {
    var merged: [EventHandlerUpdate] {
        guard !hasGeneralUpdate else {
            return [.general]
        }
        
        var updateIds = Set<BlockId>()
        var details: DetailsData?
        var syncStatus: SyncStatus?
        
        for update in self {
            switch update {
            case let .update(blockIds: blockIds):
                blockIds.forEach { updateIds.insert($0) }
            case let .details(detailsData):
                details = detailsData
            case .syncStatus(let status):
                syncStatus = status
            case .general:
                anytypeAssertionFailure("No general events soppose to be in mergedUpdates")
            }
        }
        
        var updates: [EventHandlerUpdate] = [.update(blockIds: updateIds)]
        
        details.flatMap { updates.append(.details($0)) }
        syncStatus.flatMap { updates.append(.syncStatus($0)) }
        
        return updates
    }
    
    var hasGeneralUpdate: Bool {
        contains(where: { .general == $0 })
    }
}
