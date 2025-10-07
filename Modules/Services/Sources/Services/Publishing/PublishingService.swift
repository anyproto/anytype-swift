import ProtobufMessages
import Foundation
import AnytypeCore

public protocol PublishingServiceProtocol: Sendable {
    @discardableResult
    func create(spaceId: String, objectId: String, uri: String, joinSpace: Bool) async throws -> String
    func remove(spaceId: String, objectId: String) async throws
    func list() async throws -> [PublishState]
    func list(spaceId: String) async throws -> [PublishState]
    func resolveUri(uri: String) async throws -> PublishState
    func getStatus(spaceId: String, objectId: String) async throws -> PublishState?
}

public final class PublishingService: PublishingServiceProtocol {
    
    public init() {}
    
    public func create(spaceId: String, objectId: String, uri: String, joinSpace: Bool) async throws -> String {
        let response = try await ClientCommands.publishingCreate(.with {
            $0.spaceID = spaceId
            $0.objectID = objectId
            $0.uri = uri
            $0.joinSpace = joinSpace
        }).invoke(ignoreLogErrors: .badInput, .noSuchObject, .noSuchSpace, .limitExceeded, .urlAlreadyTaken)
        
        return response.uri
    }
    
    public func remove(spaceId: String, objectId: String) async throws {
        try await ClientCommands.publishingRemove(.with {
            $0.spaceID = spaceId
            $0.objectID = objectId
        }).invoke(ignoreLogErrors: .badInput, .noSuchObject, .noSuchSpace)
    }
    
    public func list() async throws -> [PublishState] {
        try await listSites(spaceId: nil)
    }
    public func list(spaceId: String) async throws -> [PublishState] {
        try await  listSites(spaceId: spaceId)
    }
    
    private func listSites(spaceId: String?) async throws -> [PublishState] {
        let response = try await ClientCommands.publishingList(.with { populator in
            if let spaceId {
                populator.spaceID = spaceId
            }
        }).invoke(ignoreLogErrors: .badInput, .noSuchSpace)
        
        return response.publishes.map { PublishState(from: $0) }
    }
    
    public func resolveUri(uri: String) async throws -> PublishState {
        let response = try await ClientCommands.publishingResolveUri(.with {
            $0.uri = uri
        }).invoke(ignoreLogErrors: .badInput, .noSuchUri)
        
        return PublishState(from: response.publish)
    }
    
    public func getStatus(spaceId: String, objectId: String) async throws -> PublishState? {
        do {
            let response = try await ClientCommands.publishingGetStatus(.with {
                $0.spaceID = spaceId
                $0.objectID = objectId
            }).invoke(ignoreLogErrors: .badInput, .noSuchObject, .noSuchSpace, .null)
            
            return PublishState(from: response.publish)
        } catch let error as Anytype_Rpc.Publishing.GetStatus.Response.Error {
            if error.code == .null { return nil }
            else { throw error }
        }
    }
}
