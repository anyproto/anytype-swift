import Foundation
import Services

@MainActor
protocol PropertySearchModuleOutput: AnyObject {
    
    func didAddProperty(_ relationDetails: PropertyDetails)
    func didAskToShowCreateNewProperty(document: some BaseDocumentProtocol, target: PropertiesModuleTarget, searchText: String)
    
}
