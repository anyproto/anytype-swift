import Foundation
import Services
import Combine

protocol ObjectTypeProviderProtocol: AnyObject {

    var objectTypes: [ObjectType] { get }
    
    func defaultObjectType(spaceId: String) -> ObjectType?
    func defaultObjectTypePublisher(spaceId: String) -> AnyPublisher<ObjectType, Never>
    func setDefaultObjectType(type: ObjectType, spaceId: String)
    func objectType(id: String) throws -> ObjectType
    func objectType(recommendedLayout: DetailsLayout) throws -> ObjectType
    func objectType(uniqueKey: ObjectTypeUniqueKey) throws -> ObjectType
    func deleteObjectType(id: String) -> ObjectType
        
    func startSubscription() async
    func stopSubscription()
}
