import Foundation
import Services
import Combine

protocol ObjectTypeProviderProtocol: AnyObject {

    var objectTypes: [ObjectType] { get }
    var defaultObjectType: ObjectType { get }
    var defaultObjectTypePublisher: AnyPublisher<ObjectType, Never> { get }
    func setDefaulObjectType(type: ObjectType)
    
    var syncPublisher: AnyPublisher<Void, Never> { get }
    
    func objectType(id: String) -> ObjectType?
    func deleteObjectType(id: String) -> ObjectType
        
    func startSubscription() async
    func stopSubscription()
}
