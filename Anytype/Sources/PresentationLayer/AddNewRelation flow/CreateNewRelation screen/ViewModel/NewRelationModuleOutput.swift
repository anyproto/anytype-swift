import Foundation
import Services

protocol NewRelationModuleOutput: AnyObject {
    
    func didAskToShowRelationFormats(selectedFormat: SupportedRelationFormat)
    func didAskToShowObjectTypesSearch(selectedObjectTypesIds: [String])
    func didCreateRelation(_ relation: RelationDetails)
    
}
