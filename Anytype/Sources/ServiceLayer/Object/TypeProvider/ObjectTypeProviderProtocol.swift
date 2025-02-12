import Foundation
import Services
import Combine

protocol ObjectTypeProviderProtocol: AnyObject, Sendable {

    var syncPublisher: AnyPublisher<Void, Never> { get }
    
    func setDefaultObjectType(type: ObjectType, spaceId: String, route: AnalyticsDefaultObjectTypeChangeRoute)
    
    func defaultObjectType(spaceId: String) throws -> ObjectType
    func defaultObjectTypePublisher(spaceId: String) -> AnyPublisher<ObjectType, Never>
    func objectType(id: String) throws -> ObjectType
    func objectType(recommendedLayout: DetailsLayout, spaceId: String) throws -> ObjectType
    func objectType(uniqueKey: ObjectTypeUniqueKey, spaceId: String) throws -> ObjectType
    func objectTypes(spaceId: String) -> [ObjectType]
    func deletedObjectType(id: String) -> ObjectType
    
    func startSubscription(spaceId: String) async
    func stopSubscription(cleanCache: Bool) async
}

extension ObjectTypeProviderProtocol {
    func analyticsType(id: String) -> AnalyticsObjectType {
        (try? objectType(id: id))?.analyticsType ?? .custom
    }
}
