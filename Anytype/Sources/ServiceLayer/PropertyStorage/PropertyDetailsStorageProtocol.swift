import Foundation
import Services
import Combine
import AnytypeCore

protocol PropertyDetailsStorageProtocol: AnyObject, Sendable {
    
    func relationsDetails(keys: [String], spaceId: String) -> [PropertyDetails]
    func relationsDetails(key: String, spaceId: String) throws -> PropertyDetails
    func relationsDetails(bundledKey: BundledPropertyKey, spaceId: String) throws -> PropertyDetails
    
    func relationsDetails(ids: [String], spaceId: String) -> [PropertyDetails]
    func relationsDetails(spaceId: String) -> [PropertyDetails]
    
    var syncPublisher: AnyPublisher<Void, Never> { get }
    
    func startSubscription(spaceId: String) async
    func stopSubscription() async
    
    func prepareData(spaceId: String) async
}

extension PropertyDetailsStorageProtocol {
    func relationsDetails(keys: [String], spaceId: String, includeDeleted: Bool = false) -> [PropertyDetails] {
        return relationsDetails(keys: keys, spaceId: spaceId).filter { !$0.isDeleted }
    }
    
    func relationsDetailsPublisher(spaceId: String) -> AnyPublisher<[PropertyDetails], Never> {
        syncPublisher
            .compactMap { [weak self] _ in self?.relationsDetails(spaceId: spaceId) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
