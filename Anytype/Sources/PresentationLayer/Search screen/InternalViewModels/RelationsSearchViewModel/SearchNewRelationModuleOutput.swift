import Foundation
import Services

protocol RelationSearchModuleOutput: AnyObject {
    
    func didAddRelation(_ relationDetails: RelationDetails)
    func didAskToShowCreateNewRelation(document: BaseDocumentProtocol, searchText: String)
    
}
