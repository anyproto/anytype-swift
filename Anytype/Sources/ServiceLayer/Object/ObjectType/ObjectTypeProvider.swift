import ProtobufMessages
import SwiftProtobuf
import AnytypeCore
import BlocksModels

protocol ObjectTypeProviderProtocol {
    static var supportedTypeUrls: [String] { get }
    static var defaultObjectType: ObjectType { get }
    
    static func loadObjects()
    
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
        types.filter {
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
        
        return types.filter { $0.url == url }.first
    }
    
    static func loadObjects() {
        guard let types = try? Anytype_Rpc.ObjectType.List.Service.invoke().get().objectTypes else {
            return
        }
        
        cachedTypes = types.map { ObjectType(model: $0) }
    }
    
    private static var cachedTypes = [ObjectType]()
    private static var types: [ObjectType] = {
        loadObjects()
        return cachedTypes
    }()
}
