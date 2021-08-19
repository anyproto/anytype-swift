import ProtobufMessages
import SwiftProtobuf
import AnytypeCore

final class ObjectTypeProvider {
    static func objectTypes(smartblockTypes: [Anytype_Model_SmartBlockType]) -> [ObjectType] {
        types.filter {
            !Set($0.types).intersection(smartblockTypes).isEmpty
        }
    }
    
    static func objectType(url: String) -> ObjectType? {
        types.filter { $0.url == url }.first
    }    
    
    private static var cachedTypes = [ObjectType]()
    private static var types: [ObjectType] = {
        guard let types = try? Anytype_Rpc.ObjectType.List.Service.invoke().get().objectTypes else {
            return cachedTypes
        }
        
        cachedTypes = types.map { ObjectType(model: $0) }
        return cachedTypes
    }()
}
