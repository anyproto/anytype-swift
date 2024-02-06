import ProtobufMessages
import SwiftProtobuf

public protocol TypesServiceProtocol {
    func createType(name: String, spaceId: String) async throws -> ObjectDetails
}

public final class TypesService: TypesServiceProtocol {
    public init() {} 
    
    public func createType(name: String, spaceId: String) async throws -> ObjectDetails {
        let details = Google_Protobuf_Struct(
            fields: [
                BundledRelationKey.name.rawValue: name.protobufValue,
            ]
        )
        
        let result = try await ClientCommands.objectCreateObjectType(.with {
            $0.details = details
            $0.spaceID = spaceId
        }).invoke()
        
        return try ObjectDetails(protobufStruct: result.details)
    }
}
