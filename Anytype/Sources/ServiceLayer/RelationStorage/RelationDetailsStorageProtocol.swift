import Foundation
import Services
import Combine
import AnytypeCore

protocol RelationDetailsStorageProtocol: AnyObject {
    
    func relationsDetails(for links: [RelationLink], spaceId: String) -> [RelationDetails]
    func relationsDetails(for ids: [ObjectId], spaceId: String) -> [RelationDetails]
    func relationsDetails(spaceId: String) -> [RelationDetails]
    func relationsDetails(for key: BundledRelationKey, spaceId: String) throws -> RelationDetails
    func relationsDetails(for key: String, spaceId: String) throws -> RelationDetails
    var syncPublisher: AnyPublisher<Void, Never> { get }
    
    func startSubscription() async
    func stopSubscription() async
}

extension RelationDetailsStorageProtocol {
    func relationsDetails(for links: [RelationLink], spaceId: String, includeDeleted: Bool = false) -> [RelationDetails] {
        return relationsDetails(for: links, spaceId: spaceId).filter { !$0.isDeleted }
    }
    
    func relationsDetailsPublisher(spaceId: String) -> AnyPublisher<[RelationDetails], Never> {
        syncPublisher
            .compactMap { [weak self] _ in self?.relationsDetails(spaceId: spaceId) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
