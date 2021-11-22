import Foundation
import AnytypeCore

public final class ObjectDetailsStorage {
    
    private var detailsStorage = SynchronizedDictionary<BlockId, ObjectDetails>()
    
    public init() {}
    
}

extension ObjectDetailsStorage: ObjectDetailsStorageProtocol {
    
    public func get(id: BlockId) -> ObjectDetails? {
        detailsStorage[id]
    }
    
    public func add(details: ObjectDetails) {
        detailsStorage[details.id] = details
    }
    
}
