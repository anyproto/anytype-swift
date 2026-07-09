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
        
        // `Set` is an authoritative snapshot, not a patch. The proto requires the
        // client to replace its state ("can not be a partial state") and the heart
        // reference client rebuilds the entry from scratch; merging would leak keys
        // the server has dropped.
        let updatedDetails = ObjectDetails(id: id, values: data.details.fields)

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
