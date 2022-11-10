import Foundation
import BlocksModels
import Combine

protocol RelationDetailsStorageProtocol: AnyObject {
    
    var relationsDetailsPublisher: AnyPublisher<[RelationDetails], Never> { get }
    
    func relationsDetails(for links: [RelationLink]) -> [RelationDetails]
    func relationsDetails() -> [RelationDetails]
    
    func startSubscription()
    func stopSubscription()
    
//    var relationD: Published<[RelationDetails]> { get }
}
