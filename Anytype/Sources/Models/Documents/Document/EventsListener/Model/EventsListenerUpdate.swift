import BlocksModels
import AnytypeCore

enum EventsListenerUpdate: Hashable {
    case general
    case syncStatus(SyncStatus)
    case blocks(blockIds: Set<BlockId>)
    case details(id: BlockId)

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
        
        var blockIds = Set<BlockId>()
        var detailsId: BlockId? = nil
        var syncStatus: SyncStatus?
        
        for update in self {
            switch update {
            case let .blocks(blockIds: ids):
                ids.forEach { blockIds.insert($0) }
            case let .details(id):
                detailsId = id
            case .syncStatus(let status):
                syncStatus = status
            case .general:
                anytypeAssertionFailure("No general events soppose to be in mergedUpdates")
            }
        }
        
        var updates: [EventsListenerUpdate] = []
        
        if !blockIds.isEmpty {
            updates.append(.blocks(blockIds: blockIds))
        }
        
        if let id = detailsId {
            updates.append(.details(id: id))
        }
        
        syncStatus.flatMap { updates.append(.syncStatus($0)) }
        
        return updates
    }
    
    var hasGeneralUpdate: Bool {
        contains(where: { .general == $0 })
    }
    
}

