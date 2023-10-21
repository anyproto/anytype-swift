import Foundation
import AnytypeCore

final class ServerConfigurationStorage {

    enum ServerError: Error {
        case badExtension
        case accessError
    }
    
    static let shared = ServerConfigurationStorage()
    
    @UserDefault("serverFile", defaultValue: nil)
    private var serverFile: String?
    
    private enum Constants {
        static var configStorageFolde = "Servers"
    }
    
    private let storagePath: URL
    
    private init() {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let storagePath = docDir?.appendingPathComponent(Constants.configStorageFolde)
        if storagePath.isNil {
            anytypeAssertionFailure("Storage path is empty")
        }
        self.storagePath = storagePath ?? URL(fileURLWithPath: "")
        validateServerFile()
    }
    
    func addConfiguration(filePath: URL, setupAsCurrent: Bool) throws {
        guard filePath.pathExtension == "yml" else { throw ServerError.badExtension }
        
        guard filePath.startAccessingSecurityScopedResource() else { throw ServerError.accessError }
        defer { filePath.stopAccessingSecurityScopedResource() }
        
        try? FileManager.default.createDirectory(at: storagePath, withIntermediateDirectories: false)
        try FileManager.default.copyItem(at: filePath, to: storagePath.appendingPathComponent(filePath.lastPathComponent))
        if setupAsCurrent {
            setupCurrentConfiguration(fileName: filePath.lastPathComponent)
        }
    }
    
    func setupCurrentConfiguration(fileName: String?) {
        serverFile = fileName
        validateServerFile()
    }
    
    func configurations() -> [String] {
        guard let items = try? FileManager.default.contentsOfDirectory(at: storagePath, includingPropertiesForKeys: nil) else { return [] }
        return items.map { $0.lastPathComponent }
    }
    
    func currentConfiguration() -> String? {
        return serverFile
    }
    
    func currentConfigurationPath() -> URL? {
        guard let items = try? FileManager.default.contentsOfDirectory(at: storagePath, includingPropertiesForKeys: nil) else { return nil }
        return items.first { $0.lastPathComponent == serverFile }
    }
    
    // MARK: - Private func
    
    private func validateServerFile() {
        let configs = configurations()
        if let serverFile, !configs.contains(serverFile) {
            self.serverFile = nil
        }
    }
}
