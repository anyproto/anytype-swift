import Foundation
import Services

@MainActor
protocol NewRelationModuleOutput: AnyObject {
    
    func didAskToShowRelationFormats(
        selectedFormat: SupportedRelationFormat,
        onSelect: @escaping (SupportedRelationFormat) -> Void
    )
    func didAskToShowObjectTypesSearch(selectedObjectTypesIds: [String])
    func didCreateRelation(_ relation: RelationDetails)
    
}
