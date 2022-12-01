import Foundation
import BlocksModels

protocol ObjectTypeProviderProtocol: AnyObject {

    var defaultObjectType: ObjectType { get }
    func setDefaulObjectType(id: String)
    
    func isSupportedForEdit(typeId: String) -> Bool
    func objectType(id: String) -> ObjectType?
    
    func objectTypes(smartblockTypes: Set<SmartBlockType>) -> [ObjectType]
    func notVisibleTypeIds() -> [String]
    
    func startSubscription()
    func stopSubscription()
}
