import Foundation
import Services

@MainActor
protocol PropertySearchModuleOutput: AnyObject {
    
    func didAddProperty(_ relationDetails: RelationDetails)
    func didAskToShowCreateNewProperty(document: some BaseDocumentProtocol, target: PropertiesModuleTarget, searchText: String)
    
}
