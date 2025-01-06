import Foundation
import Services
import Combine
import AnytypeCore

protocol RelationDetailsStorageProtocol: AnyObject, Sendable {
    
    func relationsDetails(keys: [String], spaceId: String) -> [RelationDetails]
    func relationsDetails(key: String, spaceId: String) throws -> RelationDetails
    func relationsDetails(bundledKey: BundledRelationKey, spaceId: String) throws -> RelationDetails
    
    func relationsDetails(ids: [String], spaceId: String) -> [RelationDetails]
    func relationsDetails(spaceId: String) -> [RelationDetails]
    
    var syncPublisher: AnyPublisher<Void, Never> { get }
    
    func startSubscription(spaceId: String) async
    func stopSubscription(cleanCache: Bool) async
}

extension RelationDetailsStorageProtocol {
    func relationsDetails(keys: [String], spaceId: String, includeDeleted: Bool = false) -> [RelationDetails] {
        return relationsDetails(keys: keys, spaceId: spaceId).filter { !$0.isDeleted }
    }
    
    func relationsDetailsPublisher(spaceId: String) -> AnyPublisher<[RelationDetails], Never> {
        syncPublisher
            .compactMap { [weak self] _ in self?.relationsDetails(spaceId: spaceId) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
