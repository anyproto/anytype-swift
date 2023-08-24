import Foundation
import Services
import Combine

protocol ObjectTypeProviderProtocol: AnyObject {

    var objectTypes: [ObjectType] { get }
    
    func defaultObjectType(spaceId: String) -> ObjectType?
    func defaultObjectTypePublisher(spaceId: String) -> AnyPublisher<ObjectType, Never>
    func setDefaultObjectType(type: ObjectType, spaceId: String)
    func objectType(id: String) throws -> ObjectType
    func objectType(recommendedLayout: DetailsLayout, spaceId: String) throws -> ObjectType
    func objectType(uniqueKey: ObjectTypeUniqueKey, spaceId: String) throws -> ObjectType
    func deleteObjectType(id: String) -> ObjectType
        
    func startSubscription() async
    func stopSubscription()
}
