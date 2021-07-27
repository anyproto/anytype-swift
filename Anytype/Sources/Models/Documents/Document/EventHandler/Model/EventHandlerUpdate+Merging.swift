import BlocksModels
import AnytypeCore

extension Array where Element == EventHandlerUpdate {
    var merged: [EventHandlerUpdate] {
        guard !hasGeneralUpdate else {
            return [.general]
        }
        
        var updateIds = Set<BlockId>()
        var details: DetailsData? = nil
        
        for update in self {
            switch update {
            case let .update(blockIds: blockIds):
                blockIds.forEach { updateIds.insert($0) }
            case let .details(detailsData):
                details = detailsData
            case .general:
                anytypeAssertionFailure("No general events soppose to be in mergedUpdates")
            }
        }
        
        if let details = details {
            return [.update(blockIds: updateIds), .details(details)]
        }
        
        return [.update(blockIds: updateIds)]
    }
    
    var hasGeneralUpdate: Bool {
        contains(where: { .general == $0 })
    }
}
