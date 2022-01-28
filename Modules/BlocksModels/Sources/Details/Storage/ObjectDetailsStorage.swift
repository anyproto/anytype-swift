import Foundation
import AnytypeCore
import SwiftProtobuf

public final class ObjectDetailsStorage {
    public static let shared = ObjectDetailsStorage()
    
    private var storage = SynchronizedDictionary<BlockId, ObjectDetails>()
    
    public func get(id: BlockId) -> ObjectDetails? {
        storage[id]
    }
    
    public func add(details: ObjectDetails) {
        storage[details.id] = details
    }
    
    @discardableResult
    public func ammend(details: ObjectDetails) -> ObjectDetails {
        return ammend(id: details.id, values: details.values)
    }
    
    public func ammend(id: BlockId, values: [String: Google_Protobuf_Value]) -> ObjectDetails {
        let currentDetails = get(id: id) ?? ObjectDetails.empty(id: id)
        let updatedDetails = currentDetails.updated(by: values)
        add(details: updatedDetails)
        return updatedDetails
    }
}
