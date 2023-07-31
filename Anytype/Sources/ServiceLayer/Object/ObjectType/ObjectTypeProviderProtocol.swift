import Foundation
import Services
import Combine

protocol ObjectTypeProviderProtocol: AnyObject {

    var objectTypes: [ObjectType] { get }
    var defaultObjectType: ObjectType { get }
    var defaultObjectTypePublisher: AnyPublisher<ObjectType, Never> { get }
    func setDefaulObjectType(type: ObjectType)
    
    func objectType(id: String) throws -> ObjectType
    func objectType(recommendedLayout: DetailsLayout) throws -> ObjectType
    func objectType(uniqueKey: ObjectTypeUniqueKey) throws -> ObjectType
    func deleteObjectType(id: String) -> ObjectType
        
    func startSubscription() async
    func stopSubscription()
}
