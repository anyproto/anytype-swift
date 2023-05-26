import Foundation
import Services
import Combine
import AnytypeCore

protocol RelationDetailsStorageProtocol: AnyObject {
    
    func relationsDetails(for links: [RelationLink]) -> [RelationDetails]
    func relationsDetails(for ids: [ObjectId]) -> [RelationDetails]
    func relationsDetails() -> [RelationDetails]
    var relationsDetailsPublisher: AnyPublisher<[RelationDetails], Never> { get }
    
    func startSubscription() async
    func stopSubscription()
}

extension RelationDetailsStorageProtocol {
    func relationsDetails(for links: [RelationLink], includeDeleted: Bool = false) -> [RelationDetails] {
        return relationsDetails().filter { !$0.isDeleted }
    }
}
