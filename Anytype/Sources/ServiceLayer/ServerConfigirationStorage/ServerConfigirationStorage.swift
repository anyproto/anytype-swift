import Foundation
import AnytypeCore
@preconcurrency import Combine

protocol ServerConfigurationStorageProtocol: AnyObject, Sendable {
    var installedConfigurationsPublisher: AnyPublisher<Void, Never> { get }
    func addConfiguration(filePath: URL, setupAsCurrent: Bool) throws
    func addConfiguration(fileBase64Content: String, setupAsCurrent: Bool) throws
    func setupCurrentConfiguration(config: NetworkServerConfig)
    func configurations() -> [NetworkServerConfig]
    func currentConfiguration() -> NetworkServerConfig
    func currentConfigurationPath() -> URL?
    func installedConfigurations() -> [NetworkServerConfig]
}

final class ServerConfigurationStorage: ServerConfigurationStorageProtocol, Sendable {

    enum ServerError: Error {
        case badExtension
        case accessError
        case badEncoding
    }
    
    private let serverConfig = UserDefaultStorage<NetworkServerConfig>(key: "serverConfig", defaultValue: .anytype)
    
    private enum Constants {
        static let configStorageFolder = "Servers"
        static let pathExtension = "yml"
        
        static let deeplinkProvidedConfigName = "DeeplinkProvidedConfig.yml"
    }
    
    private let storagePath: URL
    private let installedConfigurationsSubject = CurrentValueSubject<Void, Never>(())
    
    init() {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let storagePath = docDir?.appendingPathComponent(Constants.configStorageFolder)
        if storagePath.isNil {
            anytypeAssertionFailure("Storage path is empty")
        }
        self.storagePath = storagePath ?? URL(fileURLWithPath: "")
        validateServerFile()
    }
    
    // MARK: - ServerConfigurationStorageProtocol
    
    var installedConfigurationsPublisher: AnyPublisher<Void, Never> {
        return installedConfigurationsSubject.eraseToAnyPublisher()
    }
    
    func addConfiguration(filePath: URL, setupAsCurrent: Bool) throws {
        do {
            guard filePath.pathExtension == Constants.pathExtension else { throw ServerError.badExtension }
            
            guard filePath.startAccessingSecurityScopedResource() else { throw ServerError.accessError }
            defer { filePath.stopAccessingSecurityScopedResource() }
            
            try? FileManager.default.createDirectory(at: storagePath, withIntermediateDirectories: false)
            let destination = storagePath.appendingPathComponent(filePath.lastPathComponent)
            try? FileManager.default.removeItem(at: destination)
            try FileManager.default.copyItem(at: filePath, to: destination)
            if setupAsCurrent {
                setupCurrentConfiguration(config: .file(filePath.lastPathComponent))
            }
            installedConfigurationsSubject.send(())
        } catch {
            anytypeAssertionFailure("Add configuration error", info: ["error": error.localizedDescription])
            throw error
        }
    }
    
    func addConfiguration(fileBase64Content: String, setupAsCurrent: Bool) throws {
        do {
            guard let yamlString = fileBase64Content.decodedBase64(), let data = yamlString.data(using: .utf8) else { throw ServerError.badEncoding }
            
            try? FileManager.default.createDirectory(at: storagePath, withIntermediateDirectories: false)
            let destination = storagePath.appendingPathComponent(Constants.deeplinkProvidedConfigName)
            try? FileManager.default.removeItem(at: destination)
            try data.write(to: destination)
            
            if setupAsCurrent {
                setupCurrentConfiguration(config: .file(Constants.deeplinkProvidedConfigName))
            }
            installedConfigurationsSubject.send(())
        } catch {
            anytypeAssertionFailure("Add configuration error", info: ["error": error.localizedDescription])
            throw error
        }
    }
    
    func setupCurrentConfiguration(config: NetworkServerConfig) {
        let configs = configurations()
        if configs.contains(serverConfig.value) {
            serverConfig.value = config
        }
    }
    
    func configurations() -> [NetworkServerConfig] {
        return .builder {
            NetworkServerConfig.anytype
            NetworkServerConfig.localOnly
            installedConfigurations()
        }
    }
    
    func installedConfigurations() -> [NetworkServerConfig] {
        return files().map { NetworkServerConfig.file($0) }
    }
    
    func currentConfiguration() -> NetworkServerConfig {
        return serverConfig.value
    }
    
    func currentConfigurationPath() -> URL? {
        guard let items = try? FileManager.default.contentsOfDirectory(at: storagePath, includingPropertiesForKeys: nil) else { return nil }
        return items.first { .file($0.lastPathComponent) == serverConfig.value }
    }
    
    // MARK: - Private func
    
    private func files() -> [String] {
        guard let items = try? FileManager.default.contentsOfDirectory(at: storagePath, includingPropertiesForKeys: nil)
            else { return [] }
        return items.map(\.lastPathComponent)
    }
    
    private func validateServerFile() {
        let configs = configurations()
        if !configs.contains(serverConfig.value) {
            self.serverConfig.value = .anytype
        }
    }
}
