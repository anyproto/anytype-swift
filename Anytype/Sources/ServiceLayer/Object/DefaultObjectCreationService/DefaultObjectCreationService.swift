import ProtobufMessages
import SwiftProtobuf
import Services
import AnytypeCore

protocol DefaultObjectCreationServiceProtocol: AnyObject {
    func createDefaultObject(
        name: String,
        shouldDeleteEmptyObject: Bool,
        spaceId: String
    ) async throws -> ObjectDetails
}


final class DefaultObjectCreationService: DefaultObjectCreationServiceProtocol {
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectActionsService)
    private var objectService: any ObjectActionsServiceProtocol
    
    func createDefaultObject(
        name: String,
        shouldDeleteEmptyObject: Bool,
        spaceId: String
    ) async throws -> ObjectDetails {
        
        let defaultObjectType = try await findDefaultObjectType(spaceId: spaceId)
        
        return try await objectService.createObject(
            name: name,
            typeUniqueKey: defaultObjectType.uniqueKey,
            shouldDeleteEmptyObject: shouldDeleteEmptyObject,
            shouldSelectType: true,
            shouldSelectTemplate: true,
            spaceId: spaceId,
            origin: .none,
            templateId: defaultObjectType.defaultTemplateId
        )
    }
    
    func findDefaultObjectType(spaceId: String) async throws -> ObjectType {
        if let defaultObjectType = try? objectTypeProvider.defaultObjectType(spaceId: spaceId) {
            return defaultObjectType
        }
        
        // In case no space is open, we have not started the subscription yet.
        await objectTypeProvider.startSubscription(spaceId: spaceId)
        return try objectTypeProvider.defaultObjectType(spaceId: spaceId)
    }
}
