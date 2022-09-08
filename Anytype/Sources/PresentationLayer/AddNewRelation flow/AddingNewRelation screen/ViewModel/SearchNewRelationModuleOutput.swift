import Foundation
import BlocksModels

protocol SearchNewRelationModuleOutput: AnyObject {
    
    #warning("Delete relation. Use subscription for object details")
    func didAddRelation(_ relation: Relation)
    func didAskToShowCreateNewRelation(searchText: String)
    
}
