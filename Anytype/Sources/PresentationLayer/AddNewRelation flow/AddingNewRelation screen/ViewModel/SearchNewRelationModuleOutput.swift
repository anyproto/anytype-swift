import Foundation
import BlocksModels

protocol SearchNewRelationModuleOutput: AnyObject {
    
    func didAddRelation(_ relation: RelationMetadata)
    func didAskToShowCreateNewRelation(searchText: String)
    
}
