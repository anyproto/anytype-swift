import Services
import SwiftProtobuf

protocol SetPrefilledFieldsBuilderProtocol: Sendable {
    func buildPrefilledFields(from setFilters: [SetFilter], relationsDetails: [PropertyDetails]) -> ObjectDetails
}

final class SetPrefilledFieldsBuilder: SetPrefilledFieldsBuilderProtocol, Sendable {
    
    private let prefilledConditions: [DataviewFilter.Condition] = [.allIn, .equal, .in]
    
    func buildPrefilledFields(from setFilters: [SetFilter], relationsDetails: [PropertyDetails]) -> ObjectDetails {
        var prefilledFields: [String: Google_Protobuf_Value] = [:]
        
        for relationDetails in relationsDetails {
            prefilledFields[relationDetails.key] = Google_Protobuf_Value(nilLiteral: ())
        }
        
        for setFilter in setFilters {
            if !prefilledConditions.contains(setFilter.filter.condition) ||
                !setFilter.filter.hasValue ||
                setFilter.relationDetails.isReadOnlyValue {
                continue
            }
            prefilledFields[setFilter.filter.relationKey] = setFilter.filter.value
        }
        
        return ObjectDetails(id: "", values: prefilledFields)
    }
}
