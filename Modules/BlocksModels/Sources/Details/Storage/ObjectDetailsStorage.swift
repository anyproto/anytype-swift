import Foundation
import AnytypeCore
import SwiftProtobuf
import ProtobufMessages

public final class ObjectDetailsStorage {
    public static let shared = ObjectDetailsStorage()
    
    private var storage = SynchronizedDictionary<AnytypeId, ObjectDetails>()
    
    public func get(id: AnytypeId) -> ObjectDetails? {
        storage[id]
    }
    
    public func add(details: ObjectDetails) {
        storage[details.id] = details
    }
    
    public func set(data: Anytype_Event.Object.Details.Set) -> ObjectDetails? {
        guard data.hasDetails else {
            anytypeAssertionFailure("No details in Object.Details.Set", domain: .detailsStorage)
            return nil
        }
        guard let id = data.id.asAnytypeId else {
            anytypeAssertionFailure("Id is empty in details \(data.details)", domain: .detailsStorage)
            return nil
        }
        
        let currentDetails = get(id: id) ?? ObjectDetails(id: id)
        let updatedDetails = currentDetails.updated(by: data.details.fields)
        
        add(details: updatedDetails)
        
        return updatedDetails
    }
    
    public func unset(data: Anytype_Event.Object.Details.Unset) -> ObjectDetails? {
        guard let id = data.id.asAnytypeId else {
            anytypeAssertionFailure("Id is empty in details \(data)", domain: .detailsStorage)
            return nil
        }
        
        guard let currentDetails = get(id: id) else {
            return nil
        }
        
        let updatedDetails = currentDetails.removed(keys: data.keys)
        add(details: updatedDetails)
        
        return updatedDetails
    }
    
    public func amend(data: Anytype_Event.Object.Details.Amend) -> ObjectDetails {
        return amend(id: data.id.asAnytypeId!, values: data.details.asDetailsDictionary)
    }
    
    @discardableResult
    public func amend(details: ObjectDetails) -> ObjectDetails {
        return amend(id: details.id, values: details.values)
    }
    
    public func amend(id: AnytypeId, values: [String: Google_Protobuf_Value]) -> ObjectDetails {
        let currentDetails = get(id: id) ?? ObjectDetails(id: id)
        let updatedDetails = currentDetails.updated(by: values)
        add(details: updatedDetails)
        return updatedDetails
    }
}
