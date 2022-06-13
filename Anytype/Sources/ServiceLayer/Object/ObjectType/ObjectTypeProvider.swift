import AnytypeCore
import BlocksModels
import ProtobufMessages

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
        
    static let shared = ObjectTypeProvider()
    
    // MARK: - Private variables
    
    private let service = ObjectTypesService()
    private let supportedSmartblockTypes: Set<SmartBlockType> = [.page, .profilePage, .anytypeProfile, .set]
    
    private var cachedObtainedObjectTypes: Set<ObjectType> = []
    private var cachedSupportedTypeUrls: Set<String> = []
    
    // MARK: - ObjectTypeProviderProtocol
    
    var supportedTypeUrls: [String] {
        Array(obtainedSupportedTypeUrls)
    }
    
    func isSupported(typeUrl: String) -> Bool {
        obtainedSupportedTypeUrls.contains(typeUrl)
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
    
    // MARK: - Internal func
    
    func resetCache() {
        cachedObtainedObjectTypes = []
        cachedSupportedTypeUrls = []
    }
    
    private var obtainedObjectTypes: Set<ObjectType> {
        if cachedObtainedObjectTypes.isEmpty {
            cachedObtainedObjectTypes = service.obtainObjectTypes()
        }
        
        return cachedObtainedObjectTypes
    }
    
    private var obtainedSupportedTypeUrls: Set<String> {
        if cachedSupportedTypeUrls.isEmpty {
            let result = obtainedObjectTypes.filter {
                    $0.smartBlockTypes.intersection(supportedSmartblockTypes).isNotEmpty
                }.map { $0.url }
            cachedSupportedTypeUrls = Set(result)
        }
        
        return cachedSupportedTypeUrls
    }
    
}
