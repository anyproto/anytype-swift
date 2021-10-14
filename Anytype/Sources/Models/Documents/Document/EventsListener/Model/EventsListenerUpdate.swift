import BlocksModels
import AnytypeCore

enum EventsListenerUpdate: Hashable {
    case general
    case syncStatus(SyncStatus)
    case blocks(blockIds: Set<BlockId>)
    case details(ObjectDetails)

    var hasUpdate: Bool {
        switch self {
        case .general:
            return true
        case .syncStatus:
            return true
        case .details:
            return true
        case let .blocks(blockIds):
            return !blockIds.isEmpty
        }
    }
}


extension Array where Element == EventsListenerUpdate {
    
    var merged: [EventsListenerUpdate] {
        guard !hasGeneralUpdate else {
            return [.general]
        }
        
        var updateIds = Set<BlockId>()
        var details: ObjectDetails? = nil
        var syncStatus: SyncStatus?
        
        for update in self {
            switch update {
            case let .blocks(blockIds: blockIds):
                blockIds.forEach { updateIds.insert($0) }
            case let .details(detailsData):
                details = detailsData
            case .syncStatus(let status):
                syncStatus = status
            case .general:
                anytypeAssertionFailure("No general events soppose to be in mergedUpdates")
            }
        }
        
        var updates: [EventsListenerUpdate] = [.blocks(blockIds: updateIds)]
        
        details.flatMap { updates.append(.details($0)) }
        syncStatus.flatMap { updates.append(.syncStatus($0)) }
        
        return updates
    }
    
    var hasGeneralUpdate: Bool {
        contains(where: { .general == $0 })
    }
    
}

