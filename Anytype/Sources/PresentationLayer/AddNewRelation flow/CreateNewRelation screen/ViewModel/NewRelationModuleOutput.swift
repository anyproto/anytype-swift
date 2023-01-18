import Foundation
import BlocksModels

protocol NewRelationModuleOutput: AnyObject {
    
    func didAskToShowRelationFormats(selectedFormat: SupportedRelationFormat)
    func didAskToShowObjectTypesSearch(selectedObjectTypesIds: [String])
    func didCreateRelation(_ relation: RelationDetails)
    
}
