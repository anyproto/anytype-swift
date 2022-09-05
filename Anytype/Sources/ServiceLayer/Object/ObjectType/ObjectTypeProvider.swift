import AnytypeCore
import BlocksModels
import ProtobufMessages

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
        
    static let shared = ObjectTypeProvider(service: ServiceLocator.shared.objectTypeService())
    
    // MARK: - Private variables
    
    private let service: ObjectTypesServiceProtocol
    private let supportedSmartblockTypes: Set<SmartBlockType> = [.page, .profilePage, .anytypeProfile, .set, .file]
    
    private var cachedObtainedObjectTypes: Set<ObjectType> = []
    private var cachedSupportedTypeIds: Set<String> = []
    
    private init(service: ObjectTypesServiceProtocol) {
        self.service = service
    }
    
    // MARK: - ObjectTypeProviderProtocol
    
    var supportedTypeIds: [String] {
        Array(obtainedSupportedTypeIds)
    }
    
    func isSupported(typeId: String) -> Bool {
        obtainedSupportedTypeIds.contains(typeId)
    }
    
    var defaultObjectType: ObjectType {
        UserDefaultsConfig.defaultObjectType
    }
    
    func objectType(id: String?) -> ObjectType? {
        guard let id = id else { return nil }
        
        return obtainedObjectTypes.filter { $0.id == id }.first
    }
    
    func objectTypes(smartblockTypes: Set<SmartBlockType>) -> [ObjectType] {
        obtainedObjectTypes.filter {
            $0.smartBlockTypes.intersection(smartblockTypes).isNotEmpty
        }
    }
    
    // MARK: - Internal func
    
    func resetCache() {
        cachedObtainedObjectTypes = []
        cachedSupportedTypeIds = []
    }
    
    private var obtainedObjectTypes: Set<ObjectType> {
        if cachedObtainedObjectTypes.isEmpty {
            cachedObtainedObjectTypes = service.obtainObjectTypes()
        }
        
        return cachedObtainedObjectTypes
    }
    
    private var obtainedSupportedTypeIds: Set<String> {
        if cachedSupportedTypeIds.isEmpty {
            let result = obtainedObjectTypes.filter {
                    $0.smartBlockTypes.intersection(supportedSmartblockTypes).isNotEmpty
                }.map { $0.id }
            cachedSupportedTypeIds = Set(result)
        }
        
        return cachedSupportedTypeIds
    }
    
}
