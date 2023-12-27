import Foundation
import ProtobufMessages

public final class DebugService {
    
    public init() {}
    
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
