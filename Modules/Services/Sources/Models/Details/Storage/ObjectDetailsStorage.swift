import Foundation
import AnytypeCore
import SwiftProtobuf
import ProtobufMessages
import Combine

public final class ObjectDetailsStorage {
    
    private var storage = SynchronizedDictionary<BlockId, ObjectDetails>()
    
    public init() {}
        
    public func get(id: BlockId) -> ObjectDetails? {
        guard id.isValidId else { return nil }
        return storage[id]
    }
    
    public func add(details: ObjectDetails) {
        storage[details.id] = details
    }
    
    @discardableResult
    public func amend(details: ObjectDetails) -> ObjectDetails {
        return amend(id: details.id, values: details.values)
    }
    
    private func amend(id: BlockId, values: [String: Google_Protobuf_Value]) -> ObjectDetails {
        let currentDetails = get(id: id) ?? ObjectDetails(id: id)
        let updatedDetails = currentDetails.updated(by: values)
        add(details: updatedDetails)
        return updatedDetails
    }
    
    public func removeAll() {
        storage.removeAll()
    }
}
