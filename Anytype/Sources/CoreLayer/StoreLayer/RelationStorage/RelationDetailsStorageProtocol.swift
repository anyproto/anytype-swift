import Foundation
import BlocksModels

protocol RelationDetailsStorageProtocol: AnyObject {
    
    func relationsDetails(for links: [RelationLink]) -> [RelationDetails]
    func relationsDetails() -> [RelationDetails]
    
    func startSubscription()
    func stopSubscription()
}
