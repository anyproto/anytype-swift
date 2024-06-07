import Foundation
import ProtobufMessages

public protocol DebugServiceProtocol: AnyObject, Sendable {
    func exportLocalStore() async throws -> String
    func exportStackGoroutines() async throws -> String
    func exportSpaceDebug(spaceId: String) async throws -> String
}

final class DebugService: DebugServiceProtocol {
    
    // MARK: - DebugServiceProtocol
    
    public func exportLocalStore() async throws -> String {
        let tempDirString = try FileManager.default.createTempDirectory()
        
        let response = try await ClientCommands.debugExportLocalstore(.with {
            $0.path = tempDirString
        }).invoke()
        
        return response.path
    }
    
    public func exportStackGoroutines() async throws -> String {
        let tempDirString = try FileManager.default.createTempDirectory()
        
        try await ClientCommands.debugStackGoroutines(.with {
            $0.path = tempDirString
        }).invoke()
        
        return tempDirString
    }
    
    public func exportSpaceDebug(spaceId: String) async throws -> String {
        let result = try await ClientCommands.debugSpaceSummary(.with {
            $0.spaceID = spaceId
        }).invoke()
        return try result.jsonString()
    }
}

extension FileManager {
    func createTempDirectory() throws -> String {
        let tempDirectory = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(atPath: tempDirectory,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
        return tempDirectory
    }
}
