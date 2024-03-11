import Foundation
import UIKit
import AnytypeCore
import Services
import ZIPFoundation

@MainActor
final class DebugMenuViewModel: ObservableObject {
    
    @Published private(set) var isRemovingRecoveryPhraseInProgress = false
    @Published var shareUrlFile: URL?
    @Published var showZipPicker = false
    @Published private(set) var flags = [FeatureFlagSection]()
    
    @Injected(\.debugService)
    private var debugService: DebugServiceProtocol
    @Injected(\.localAuthService)
    private var localAuthService: LocalAuthServiceProtocol
    @Injected(\.localRepoService)
    private var localRepoService: LocalRepoServiceProtocol
    @Injected(\.authService)
    private var authService: AuthServiceProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: ApplicationStateServiceProtocol
    @Injected(\.activeWorkpaceStorage)
    private var activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    
    init() {
        updateFlags()
    }
    
    func removeRecoveryPhraseFromDevice() {
        isRemovingRecoveryPhraseInProgress = true
        Task {
            do {
                try await ServiceLocator.shared.authService().logout(removeData: false)
                try ServiceLocator.shared.seedService().removeSeed()
                ServiceLocator.shared.applicationStateService().state = .auth
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
    
    func getLocalStoreData() {
        Task {
            try await localAuthService.auth(reason: "Share local store")
            let path = try await debugService.exportLocalStore()
            let zipFile = FileManager.default.createTempDirectory().appendingPathComponent("localstore.zip")
            try FileManager.default.zipItem(at: URL(fileURLWithPath: path), to: zipFile)
            shareUrlFile = zipFile
        }
    }
    
    func getGoroutinesData() {
        Task {
            let path = try await debugService.exportStackGoroutines()
            let zipFile = FileManager.default.createTempDirectory().appendingPathComponent("stackGoroutines.zip")
            try FileManager.default.zipItem(at: URL(fileURLWithPath: path), to: zipFile)
            shareUrlFile = zipFile
        }
    }
    
    func zipWorkingDirectory() {
        Task {
            try await localAuthService.auth(reason: "Share working directory")
            let zipFile = FileManager.default.createTempDirectory().appendingPathComponent("workingDirectory.zip")
            try FileManager.default.zipItem(at: localRepoService.middlewareRepoURL, to: zipFile)
            shareUrlFile = zipFile
        }
    }
    
    func unzipWorkingDirectory() {
        showZipPicker.toggle()
    }
    
    func onSelectUnzipFile(url: URL) {
        Task {
            let middlewareTempPath = FileManager.default.createTempDirectory()
            try FileManager.default.unzipItem(at: url, to: middlewareTempPath)
            try await authService.logout(removeData: false)
            applicationStateService.state = .initial
            let middlewareRepoURL = localRepoService.middlewareRepoURL
            try? FileManager.default.removeItem(at: middlewareRepoURL)
            try FileManager.default.moveItem(
                at: middlewareTempPath.appendingPathComponent(middlewareRepoURL.lastPathComponent),
                to: middlewareRepoURL
            )
        }
    }
    
    func onSpaceDebug() async throws {
        let jsonDebug = try await debugService.exportSpaceDebug(spaceId: activeWorkpaceStorage.workspaceInfo.accountSpaceId)
        let jsonFile = FileManager.default.createTempDirectory().appendingPathComponent("spaceInfo.json")
        try jsonDebug.write(to: jsonFile, atomically: true, encoding: .utf8)
        shareUrlFile = jsonFile
    }
    
    // MARK: - Private
    
    private func updateFlags() {
       let allFlags = FeatureFlags.features.sorted { $0.title < $1.title }
            .map { flag in
                FeatureFlagViewModel(
                    description: flag,
                    value: FeatureFlags.value(for: flag),
                    onChange: { [weak self] in
                        FeatureFlags.update(key: flag, value: $0)
                        self?.updateFlags()
                    }
                )
            }
        
        let productionRows = allFlags.filter { $0.description.type != .debug }
        let debugRows = allFlags.filter { $0.description.type == .debug }
        
        flags = [
                FeatureFlagSection(title: "Features", rows: productionRows),
                FeatureFlagSection(title: "Debug", rows: debugRows),
            ]
    }
}
