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
    
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let objectService: ObjectActionsServiceProtocol
    
    init(
        objectTypeProvider: ObjectTypeProviderProtocol,
        objectService: ObjectActionsServiceProtocol
    ) {
        self.objectTypeProvider = objectTypeProvider
        self.objectService = objectService
    }
    
    func createDefaultObject(
        name: String,
        shouldDeleteEmptyObject: Bool,
        spaceId: String
    ) async throws -> ObjectDetails {
        let defaultObjectType = try objectTypeProvider.defaultObjectType(spaceId: spaceId)
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
}
