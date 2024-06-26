import Foundation
import Services

@MainActor
protocol RelationSearchModuleOutput: AnyObject {
    
    func didAddRelation(_ relationDetails: RelationDetails)
    func didAskToShowCreateNewRelation(document: some BaseDocumentProtocol, target: RelationsModuleTarget, searchText: String)
    
}
