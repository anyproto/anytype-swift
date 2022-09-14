import BlocksModels
import SwiftProtobuf

protocol SetFilterPrefilledFieldsBuilderProtocol {
    func buildPrefilledFields(from setFilters: [SetFilter]) -> [String: Google_Protobuf_Value]
}

final class SetFilterPrefilledFieldsBuilder: SetFilterPrefilledFieldsBuilderProtocol {
    
    private let prefilledConditions: [DataviewFilter.Condition] = [.allIn, .equal, .in]
    
    func buildPrefilledFields(from setFilters: [SetFilter]) -> [String: Google_Protobuf_Value] {
        var prefilledFields: [String: Google_Protobuf_Value] = [:]
        
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
