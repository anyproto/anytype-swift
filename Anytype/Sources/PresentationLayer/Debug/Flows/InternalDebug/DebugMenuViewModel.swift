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
    @Published var sectionExpanded: [String: Bool] = [:]
    @Published var searchText = ""
    @Published var secureAlertData: SecureAlertData?
    
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
    @Injected(\.applePushNotificationService)
    private var applePushNotificationService: any ApplePushNotificationServiceProtocol
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    var shouldRunDebugProfilerOnNextStartup: Bool {
        get {
            debugService.shouldRunDebugProfilerOnNextStartup
        } set {
            debugService.shouldRunDebugProfilerOnNextStartup = newValue
        }
    }
    
    init() {
        updateFlags()
        initializeSectionStates()
        debugService.debugRunProfilerData.receiveOnMain().assign(to: &$debugRunProfilerData)
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
    
    func getLocalStoreData() async throws {
        try await localAuthWithContinuation(reason: "Share local store") { [weak self] in
            guard let self else { return }
            let path = try await debugService.exportLocalStore()
            let zipFile = FileManager.default.createTempDirectory().appendingPathComponent("localstore.zip")
            try FileManager.default.zipItem(at: URL(fileURLWithPath: path), to: zipFile)
            shareUrlFile = zipFile
        }
    }
    
    func getGoroutinesData() async throws {
        shareUrlFile = try await debugService.exportStackGoroutinesZip()
    }
    
    func zipWorkingDirectory() async throws {
        try await localAuthWithContinuation(reason: "Share working directory") { [weak self] in
            guard let self else { return }
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
    
    func getFirebaseNotificationToken() {
        Messaging.messaging().token { [weak self] token, error in
            Task { @MainActor  [weak self] in
                guard let self, let token else { return }
                pushToken = token.identifiable
            }
        }
    }
    
    func getAppleNotificationToken() {
        pushToken = applePushNotificationService.token()?.identifiable
    }
    
    func readAllMessages() async throws {
        try await chatService.readAllMessages()
    }
    
    // MARK: - Private
    
    private func updateFlags() {
        let allFlags = FeatureFlags.features.sorted { first, second in
            switch (first.type, second.type) {
            case (.feature, .debug):
                // Features come before debug
                return true
            case (.debug, .feature):
                // Debug comes after features
                return false
            case (.debug, .debug):
                // Both are debug, sort by title
                return first.title < second.title
            case (.feature(let author1, let version1), .feature(let author2, let version2)):
                // Both are features, sort by version first
                if version1 != version2 {
                    return version1 < version2
                }
                // If versions are the same, sort by author
                return author1 < author2
            }
        }
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
    
    private func localAuthWithContinuation(reason: String, continuation: @escaping () async throws -> Void) async throws {
        do {
            try await localAuthService.auth(reason: reason)
            try await continuation()
        } catch LocalAuthServiceError.passcodeNotSet {
            secureAlertData = SecureAlertData(completion: { [weak self] proceed in
                guard proceed else { return }
                try await continuation()
                self?.secureAlertData = nil
            })
        }
    }
    
    // MARK: - Section State Management
    
    var filteredSections: [FeatureFlagSection] {
        guard !searchText.isEmpty else { return flags }
        
        let searchLower = searchText.lowercased()
        
        return flags.compactMap { section in
            let filteredRows = section.rows.filter { row in
                matchesSearch(row: row, searchText: searchLower)
            }
            
            return filteredRows.isEmpty ? nil : FeatureFlagSection(title: section.title, rows: filteredRows)
        }
    }
    
    private func matchesSearch(row: FeatureFlagViewModel, searchText: String) -> Bool {
        let description = row.description
        
        return description.title.lowercased().contains(searchText) ||
               description.type.author?.lowercased().contains(searchText) ?? false ||
               description.type.releaseVersion?.lowercased().contains(searchText) ?? false
    }
    
    private func initializeSectionStates() {
        flags.forEach { section in
            sectionExpanded[section.title] = sectionExpanded[section.title] ?? true
        }
    }
}
