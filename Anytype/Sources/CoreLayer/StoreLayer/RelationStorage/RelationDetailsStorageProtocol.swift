import Foundation
import BlocksModels
import Combine
import AnytypeCore

protocol RelationDetailsStorageProtocol: AnyObject {
    
    func relationsDetails(for links: [RelationLink]) -> [RelationDetails]
    func relationsDetails() -> [RelationDetails]
    var relationsDetailsPublisher: AnyPublisher<[RelationDetails], Never> { get }
    
    func startSubscription()
    func stopSubscription()
}
