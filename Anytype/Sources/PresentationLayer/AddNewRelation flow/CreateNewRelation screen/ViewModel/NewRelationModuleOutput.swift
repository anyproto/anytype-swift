import Foundation
import BlocksModels

protocol NewRelationModuleOutput: AnyObject {
    
    func didAskToShowRelationFormats()
    func didAskToShowObjectTypesSearch(selectedObjectTypesIds: [String])
    func didCreateRelation(_ relationMetadata: RelationMetadata)
}
