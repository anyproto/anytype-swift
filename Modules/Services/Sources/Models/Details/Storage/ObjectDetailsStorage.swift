import Foundation
import AnytypeCore
import SwiftProtobuf
import ProtobufMessages
import Combine

public final class ObjectDetailsStorage: Sendable {
    
    private let storage = SynchronizedDictionary<String, ObjectDetails>()
    
    public init() {}
        
    public func get(id: String) -> ObjectDetails? {
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
    
    private func amend(id: String, values: [String: Google_Protobuf_Value]) -> ObjectDetails {
        let currentDetails = get(id: id) ?? ObjectDetails(id: id)
        let updatedDetails = currentDetails.updated(by: values)
        add(details: updatedDetails)
        return updatedDetails
    }
    
    public func removeAll() {
        storage.removeAll()
    }
}
