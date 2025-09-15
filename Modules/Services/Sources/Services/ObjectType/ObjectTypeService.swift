import Foundation
import ProtobufMessages

public protocol ObjectTypeServiceProtocol: AnyObject, Sendable {
    func setOrder(spaceId: String, typeIds: [String]) async throws
}

final class ObjectTypeService: ObjectTypeServiceProtocol, Sendable {
    
    func setOrder(spaceId: String, typeIds: [String]) async throws {
        try await ClientCommands.objectTypeSetOrder(.with {
            $0.spaceID = spaceId
            $0.typeIds = typeIds
        }).invoke()
    }
}
