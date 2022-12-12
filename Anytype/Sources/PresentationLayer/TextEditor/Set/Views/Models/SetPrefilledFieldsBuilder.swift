import BlocksModels
import SwiftProtobuf

protocol SetPrefilledFieldsBuilderProtocol {
    func buildPrefilledFields(from setFilters: [SetFilter], relationsDetails: [RelationDetails]) -> [String: Google_Protobuf_Value]
}

final class SetPrefilledFieldsBuilder: SetPrefilledFieldsBuilderProtocol {
    
    private let prefilledConditions: [DataviewFilter.Condition] = [.allIn, .equal, .in]
    
    func buildPrefilledFields(from setFilters: [SetFilter], relationsDetails: [RelationDetails]) -> [String: Google_Protobuf_Value] {
        var prefilledFields: [String: Google_Protobuf_Value] = [:]
        
        for relationDetails in relationsDetails {
            prefilledFields[relationDetails.id] = Google_Protobuf_Value(nilLiteral: ())
        }
        
        for setFilter in setFilters {
            if !prefilledConditions.contains(setFilter.filter.condition) ||
                !setFilter.filter.hasValue ||
                setFilter.relationDetails.isReadOnlyValue {
                continue
            }
            prefilledFields[setFilter.filter.relationKey] = setFilter.filter.value
        }
        
        return prefilledFields
    }
}
