import Foundation
import BlocksModels

protocol SearchNewRelationModuleOutput: AnyObject {
    
    func didAddRelation(_ relationDetails: RelationDetails)
    func didAskToShowCreateNewRelation(searchText: String)
    
}
