import SwiftProtobuf
import AnytypeCore

public extension Array where Element == Google_Protobuf_Struct {
    
    var asDetais: [ObjectDetails] {
        map(\.fields)
            .compactMap { fields in
                guard let id = fields["id"]?.stringValue, id.isValidId else {
                    anytypeAssertionFailure("Empty id in sybscription data \(fields)", domain: .subscriptionService)
                    return nil
                }
                
                return ObjectDetails(id: id, values: fields)
            }
    }
    
}
