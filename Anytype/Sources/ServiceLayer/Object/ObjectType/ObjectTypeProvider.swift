import AnytypeCore
import BlocksModels
import ProtobufMessages

final class ObjectTypeProvider: ObjectTypeProviderProtocol {
        
    static let service = ObjectTypesService()
    
    // MARK: - Internal vars
    
    static var supportedTypeUrls: [String] {
        let smartblockTypes: [SmartBlockType] = [
            .page, .profilePage, .anytypeProfile, .set
        ]
        
        return objectTypes(smartblockTypes: smartblockTypes).map { $0.url }
        
    }
    
    static var defaultObjectType: ObjectType {
        UserDefaultsConfig.defaultObjectType
    }
    
    // MARK: - Internal func
    
    static func isSupported(typeUrl: String) -> Bool {
        supportedTypeUrls.contains(typeUrl)
    }
    
    static func objectType(url: String?) -> ObjectType? {
        guard let url = url else {
            return nil
        }
        
        return loadObjectTypes().filter { $0.url == url }.first
    }
    
    static func objectTypes(smartblockTypes: [SmartBlockType]) -> [ObjectType] {
        //implement filterring at once on fetching
        loadObjectTypes().filter {
            $0.smartBlockTypes.intersection(smartblockTypes).isNotEmpty
        }
    }
    
    // MARK: - Private func
    
    private static func loadObjectTypes() -> Set<ObjectType> {
        service.obtainObjectTypes()
    }
    
}
