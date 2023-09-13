import Foundation
import AnytypeCore
import ProtobufMessages
import SwiftProtobuf

public extension ObjectDetailsStorage {
    
     func set(data: Anytype_Event.Object.Details.Set) -> ObjectDetails? {
        guard data.hasDetails else {
            anytypeAssertionFailure("No details in Object.Details.Set")
            return nil
        }
        let id = data.id
        guard id.isValidId else {
            anytypeAssertionFailure("Id is empty in details", info: ["id": id])
            return nil
        }
        
        let currentDetails = get(id: id) ?? ObjectDetails(id: id)
        let updatedDetails = currentDetails.updated(by: data.details.fields)
        
        add(details: updatedDetails)
        
        return updatedDetails
    }
    
    func unset(data: Anytype_Event.Object.Details.Unset) -> ObjectDetails? {
        let id = data.id
        guard id.isValidId else {
            anytypeAssertionFailure("Id is empty in details", info: ["id": id])
            return nil
        }
        
        guard let currentDetails = get(id: id) else {
            return nil
        }
        
        let updatedDetails = currentDetails.removed(keys: data.keys)
        add(details: updatedDetails)
        
        return updatedDetails
    }
    
    func amend(data: Anytype_Event.Object.Details.Amend) -> ObjectDetails? {
        let id = data.id
        guard id.isValidId else { return nil }
        
        return amend(details: ObjectDetails(id: data.id, values: data.details.asDetailsDictionary))
    }
}
