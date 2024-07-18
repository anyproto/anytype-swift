import Services
import ZIPFoundation
import AnytypeCore
import Foundation

extension DebugServiceProtocol {
    public func exportStackGoroutinesZip() async throws -> URL {
        let path = try await exportStackGoroutines()
        let zipFile = FileManager.default.createTempDirectory().appendingPathComponent("stackGoroutines.zip")
        try FileManager.default.zipItem(at: URL(fileURLWithPath: path), to: zipFile)
        
        return zipFile
    }
}
