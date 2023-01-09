import Foundation
import BlocksModels

protocol RelationSearchModuleOutput: AnyObject {
    
    func didAddRelation(_ relationDetails: RelationDetails)
    func didAskToShowCreateNewRelation(searchText: String)
    
}
