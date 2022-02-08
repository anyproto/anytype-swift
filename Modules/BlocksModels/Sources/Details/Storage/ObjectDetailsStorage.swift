import Foundation
import AnytypeCore

public final class ObjectDetailsStorage {
    public static let shared = ObjectDetailsStorage()
    
    private var storage = SynchronizedDictionary<BlockId, ObjectDetails>()
    
    public func get(id: BlockId) -> ObjectDetails? {
        storage[id]
    }
    
    public func add(details: ObjectDetails) {
        storage[details.id] = details
    }
    
}
