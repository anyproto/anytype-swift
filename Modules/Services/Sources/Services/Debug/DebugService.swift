import Foundation
import ProtobufMessages
import AnytypeCore

public protocol DebugServiceProtocol: AnyObject, Sendable {
    func exportLocalStore() async throws -> String
    func exportStackGoroutines() async throws -> String
    func exportSpaceDebug(spaceId: String) async throws -> String
    func debugRunProfiler() async throws -> String
    func debugStat() async throws -> URL
}

final class DebugService: DebugServiceProtocol {
    // MARK: - DebugServiceProtocol
    
    public func exportLocalStore() async throws -> String {
        let tempDirString = FileManager.default.createTempDirectory().path
        
        let response = try await ClientCommands.debugExportLocalstore(.with {
            $0.path = tempDirString
        }).invoke()
        
        return response.path
    }
    
    public func exportStackGoroutines() async throws -> String {
        let tempDirString = FileManager.default.createTempDirectory().path
        
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
    
    public func debugRunProfiler() async throws -> String {
        return try await ClientCommands.debugRunProfiler(.with {
            $0.durationInSeconds = 60
        }).invoke().path
    }
    
    public func debugStat() async throws -> URL {
        let jsonContent = try await ClientCommands.debugStat().invoke().jsonStat
        let jsonFile = FileManager.default.createTempDirectory().appendingPathComponent("debugStat.json")
        try jsonContent.write(to: jsonFile, atomically: true, encoding: .utf8)
        
        return jsonFile
    }
}
