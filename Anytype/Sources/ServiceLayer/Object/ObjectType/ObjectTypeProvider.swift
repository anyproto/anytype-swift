import ProtobufMessages
import SwiftProtobuf
import AnytypeCore
import BlocksModels

protocol ObjectTypeProviderProtocol {
    static var supportedTypeUrls: [String] { get }
    static var defaultObjectType: ObjectType { get }
    
    static func isSupported(typeUrl: String) -> Bool
    
    static func objectTypes(smartblockTypes: [Anytype_Model_SmartBlockType]) -> [ObjectType]
    static func objectType(url: String?) -> ObjectType?
}

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
    
    static var supportedTypeUrls: [String] {
        let smartblockTypes: [Anytype_Model_SmartBlockType] = [.page, .profilePage, .anytypeProfile, .set]
        
        return objectTypes(smartblockTypes: smartblockTypes).map { $0.url } +
        [ObjectTemplateType.BundledType.note.rawValue]
    }
    
    static var defaultObjectType: ObjectType {
        objectType(url: UserDefaultsConfig.defaultObjectType) ?? .fallbackType
    }
    
    static func objectTypes(smartblockTypes: [Anytype_Model_SmartBlockType]) -> [ObjectType] {
        loadObjects().filter {
            !Set($0.types).intersection(smartblockTypes).isEmpty
        }
    }
    
    static func isSupported(typeUrl: String) -> Bool {
        supportedTypeUrls.contains(typeUrl)
    }
    
    static func objectType(url: String?) -> ObjectType? {
        guard let url = url else {
            return nil
        }
        
        return loadObjects().filter { $0.url == url }.first
    }
    
    private static func loadObjects() -> [ObjectType]  {
        let result = Anytype_Rpc.ObjectType.List.Service.invoke()
        switch result {
        case .success(let response):
            let error = response.error
            switch error.code {
            case .null:
                let objectTypes = response.objectTypes
                
                guard objectTypes.isNotEmpty else {
                    anytypeAssertionFailure("ObjectTypeList response is empty", domain: .objectTypeProvider)
                    return []
                }
                
                return objectTypes.map { ObjectType(model: $0) }
            case .unknownError, .badInput, .UNRECOGNIZED:
                anytypeAssertionFailure(error.description_p, domain: .objectTypeProvider)
                return []
            }
        case .failure(let error):
            anytypeAssertionFailure(error.localizedDescription, domain: .objectTypeProvider)
            return []
        }
    }
}
