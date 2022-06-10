import AnytypeCore
import BlocksModels
import ProtobufMessages

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
        
    static let shared = ObjectTypeProvider()
    
    // MARK: - Private variables
    
    private let service = ObjectTypesService()
    private let supportedSmartblockTypes: Set<SmartBlockType> = [.page, .profilePage, .anytypeProfile, .set]
    
    private lazy var obtainedObjectTypes: Set<ObjectType> = {
        service.obtainObjectTypes()
    }()
    
    private lazy var cachedSupportedTypeUrls: Set<String> = {
        let result = obtainedObjectTypes.filter {
                $0.smartBlockTypes.intersection(supportedSmartblockTypes).isNotEmpty
            }.map { $0.url }
        return Set(result)
    }()
    
    // MARK: - ObjectTypeProviderProtocol
    
    var supportedTypeUrls: [String] {
        Array(cachedSupportedTypeUrls)
    }
    
    func isSupported(typeUrl: String) -> Bool {
        cachedSupportedTypeUrls.contains(typeUrl)
    }
    
    var defaultObjectType: ObjectType {
        UserDefaultsConfig.defaultObjectType
    }
    
    func objectType(url: String?) -> ObjectType? {
        guard let url = url else { return nil }
        
        return obtainedObjectTypes.filter { $0.url == url }.first
    }
    
    func objectTypes(smartblockTypes: Set<SmartBlockType>) -> [ObjectType] {
        obtainedObjectTypes.filter {
            $0.smartBlockTypes.intersection(smartblockTypes).isNotEmpty
        }
    }
    
}
