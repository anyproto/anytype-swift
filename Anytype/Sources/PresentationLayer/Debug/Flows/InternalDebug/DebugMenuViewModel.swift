import Foundation
import UIKit
import AnytypeCore
import Services
import ZIPFoundation
import FirebaseMessaging


@MainActor
final class DebugMenuViewModel: ObservableObject {
    
    @Published private(set) var isRemovingRecoveryPhraseInProgress = false
    @Published var shareUrlFile: URL?
    @Published var showZipPicker = false
    @Published private(set) var flags = [FeatureFlagSection]()
    @Published var pushToken: StringIdentifiable?
    @Published var debugRunProfilerData = DebugRunProfilerState.empty
    
    @Injected(\.userDefaultsStorage)
    var userDefaults: any UserDefaultsStorageProtocol
    
    @Injected(\.debugService)
    private var debugService: any DebugServiceProtocol
    @Injected(\.localAuthService)
    private var localAuthService: any LocalAuthServiceProtocol
    @Injected(\.localRepoService)
    private var localRepoService: any LocalRepoServiceProtocol
    @Injected(\.authService)
    private var authService: any AuthServiceProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    @Injected(\.seedService)
    private var seedService: any SeedServiceProtocol
    
    var shouldRunDebugProfilerOnNextStartup: Bool {
        get {
            debugService.shouldRunDebugProfilerOnNextStartup
        } set {
            debugService.shouldRunDebugProfilerOnNextStartup = newValue
        }
    }
    
    init() {
        updateFlags()
        debugService.debugRunProfilerData.assign(to: &$debugRunProfilerData)
    }
    
    func removeRecoveryPhraseFromDevice() {
        isRemovingRecoveryPhraseInProgress = true
        Task {
            do {
                try await authService.logout(removeData: false)
                try seedService.removeSeed()
                applicationStateService.state = .auth
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
        Task { shareUrlFile = try await debugService.exportStackGoroutinesZip() }
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
    
    func onDebugRunProfiler() {
        debugService.startDebugRunProfiler()
    }
    
    func shareUrlContent(url: URL) {
        shareUrlFile = url
    }
    
    func debugStat() async throws {
        shareUrlFile = try await debugService.debugStat()
    }
    
    func getNotificationToken() {
        Messaging.messaging().token { [weak self] token, error in
            guard let self, let token else { return }
            pushToken = token.identifiable
        }
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
