import Foundation
import ProtobufMessages
import AnytypeCore

public protocol WorkspaceServiceProtocol {
    func installObjects(spaceId: String, objectIds: [String]) async throws -> [String]
    func installObject(spaceId: String, objectId: String) async throws -> ObjectDetails
    func removeObject(spaceId: String, objectId: String) async throws
    
    func createSpace(name: String, gradient: GradientId, accessibility: SpaceAccessibility, useCase: UseCase) async throws -> String
    func workspaceOpen(spaceId: String) async throws -> AccountInfo
    func workspaceSetDetails(spaceId: String, details: [WorkspaceSetDetails]) async throws
    func deleteSpace(spaceId: String) async throws
}

public final class WorkspaceService: WorkspaceServiceProtocol {
    
    public init() {}
    
    // MARK: - WorkspaceServiceProtocol
    
    public func installObjects(spaceId: String, objectIds: [String]) async throws -> [String] {
        try await ClientCommands.workspaceObjectListAdd(.with {
            $0.objectIds = objectIds
            $0.spaceID = spaceId
		}).invoke()
			.objectIds
    }
    
    public func installObject(spaceId: String, objectId: String) async throws -> ObjectDetails {
        let result = try await ClientCommands.workspaceObjectAdd(.with {
            $0.objectID = objectId
            $0.spaceID = spaceId
        }).invoke()
        
		return try ObjectDetails(protobufStruct: result.details)
    }
    
    public func removeObject(spaceId: String, objectId: String) async throws {
        try await ClientCommands.workspaceObjectListRemove(.with {
            $0.objectIds = [objectId]
        }).invoke()
    }
    
    public func createSpace(name: String, gradient: GradientId, accessibility: SpaceAccessibility, useCase: UseCase) async throws -> String {
        let result = try await ClientCommands.workspaceCreate(.with {
            $0.details.fields[BundledRelationKey.name.rawValue] = name.protobufValue
            $0.details.fields[BundledRelationKey.iconOption.rawValue] = gradient.rawValue.protobufValue
            $0.details.fields[BundledRelationKey.spaceAccessibility.rawValue] = accessibility.rawValue.protobufValue
            $0.useCase = useCase.toMiddleware()
        }).invoke()
        return result.spaceID
    }
    
    public func workspaceOpen(spaceId: String) async throws -> AccountInfo {
        let result = try await ClientCommands.workspaceOpen(.with {
            $0.spaceID = spaceId
        }).invoke()
        
        return result.info.asModel
    }
    
    public func workspaceSetDetails(spaceId: String, details: [WorkspaceSetDetails]) async throws {
        try await ClientCommands.workspaceSetInfo(.with {
            $0.spaceID = spaceId
            for detail in details {
                $0.details.fields[detail.key] = detail.value
            }
        }).invoke()
    }
    
    public func deleteSpace(spaceId: String) async throws {
        try await ClientCommands.spaceDelete(.with {
            $0.spaceID = spaceId
        }).invoke()
    }
}
