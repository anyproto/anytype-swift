import Foundation
import AnytypeCore
import SwiftProtobuf
import ProtobufMessages

public final class ObjectDetailsStorage {
    public static let shared = ObjectDetailsStorage()
    
    private var storage = SynchronizedDictionary<BlockId, ObjectDetails>()
    
    public func get(id: BlockId) -> ObjectDetails? {
        storage[id]
    }
    
    public func add(details: ObjectDetails) {
        storage[details.id] = details
    }
    
    public func set(data: Anytype_Event.Object.Details.Set) -> ObjectDetails? {
        guard data.hasDetails else {
            anytypeAssertionFailure("No details in Object.Details.Set", domain: .diskStorage)
            return nil
        }
        guard data.id.isNotEmpty else {
            anytypeAssertionFailure("Id is empty in details \(data.details)", domain: .diskStorage)
            return nil
        }
        
        let currentDetails = get(id: data.id) ?? ObjectDetails.empty(id: data.id)
        let updatedDetails = currentDetails.updated(by: data.details.fields)
        
        add(details: updatedDetails)
        
        return updatedDetails
    }
    
    public func unset(data: Anytype_Event.Object.Details.Unset) -> ObjectDetails? {
        guard let currentDetails = get(id: data.id) else {
            return nil
        }
        
        let updatedDetails = currentDetails.removed(keys: data.keys)
        add(details: updatedDetails)
        
        return updatedDetails
    }
    
    public func amend(data: Anytype_Event.Object.Details.Amend) -> ObjectDetails {
        return amend(id: data.id, values: data.details.asDetailsDictionary)
    }
    
    @discardableResult
    public func amend(details: ObjectDetails) -> ObjectDetails {
        return amend(id: details.id, values: details.values)
    }
    
    public func amend(id: BlockId, values: [String: Google_Protobuf_Value]) -> ObjectDetails {
        let currentDetails = get(id: id) ?? ObjectDetails.empty(id: id)
        let updatedDetails = currentDetails.updated(by: values)
        add(details: updatedDetails)
        return updatedDetails
    }
}
