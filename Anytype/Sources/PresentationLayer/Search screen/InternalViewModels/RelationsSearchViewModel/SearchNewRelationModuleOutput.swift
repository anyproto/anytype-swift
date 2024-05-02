import Foundation
import Services

@MainActor
protocol RelationSearchModuleOutput: AnyObject {
    
    func didAddRelation(_ relationDetails: RelationDetails)
    func didAskToShowCreateNewRelation(document: BaseDocumentProtocol, target: RelationsModuleTarget, searchText: String)
    
}
