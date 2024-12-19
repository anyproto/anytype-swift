import ProtobufMessages
import SwiftProtobuf
import Services
import AnytypeCore

protocol DefaultObjectCreationServiceProtocol: AnyObject, Sendable {
    func createDefaultObject(
        name: String,
        shouldDeleteEmptyObject: Bool,
        spaceId: String
    ) async throws -> ObjectDetails
}


final class DefaultObjectCreationService: DefaultObjectCreationServiceProtocol, Sendable {
    
    private let objectTypeProvider: any ObjectTypeProviderProtocol = Container.shared.objectTypeProvider()
    private let objectService: any ObjectActionsServiceProtocol = Container.shared.objectActionsService()
    
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
