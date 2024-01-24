import Foundation
import UIKit
import AnytypeCore
import Services

@MainActor
final class DebugMenuViewModel: ObservableObject {
    
    @Published private(set) var isRemovingRecoveryPhraseInProgress = false
    @Published var localStoreURL: URL?
    @Published var stackGoroutinesURL: URL?
    @Published var workingDirectoryURL: URL?
    @Published private(set) var flags = [FeatureFlagSection]()
    
    private let debugService = DebugService()
    
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
        Task { @MainActor in
            do {
                let path = try await debugService.exportLocalStore()
                guard let zipURL = compressFilesToZip(directoryPath: URL(fileURLWithPath: path), zipFileName: "localstore.zip") else {
                    return
                }
                self.localStoreURL = zipURL
            } catch {
                anytypeAssertionFailure("Can't export localstore")
            }
        }
    }
    
    func getGoroutinesData() {
        Task { @MainActor in
            do {
                let path = try await debugService.exportStackGoroutines()
                guard let zipURL = compressFilesToZip(directoryPath: URL(fileURLWithPath: path), zipFileName: "stackGoroutines.zip") else {
                    return
                }
                self.stackGoroutinesURL = zipURL
            } catch {
                anytypeAssertionFailure("Can't export stackGoroutines")
            }
        }
    }
    
    func zipWorkingDirectory() {
        LocalAuthService().auth(reason: "Zip working directory") { [weak self] didComplete in
            guard didComplete, let self else {
                return
            }
            let workingDirectory = LocalRepoService().middlewareRepoPath
            guard let zipURL = compressFilesToZip(
                directoryPath: URL(fileURLWithPath: workingDirectory),
                zipFileName: "workingDirectory.zip"
            ) else {
                return
            }
            
            workingDirectoryURL = zipURL
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

private func compressFilesToZip(directoryPath: URL, zipFileName: String) -> URL? {
    let coordinator = NSFileCoordinator()
    var error: NSError? = nil
    var archiveUrl: URL?
    coordinator.coordinate(readingItemAt: directoryPath, options: [.forUploading], error: &error) { (zipUrl) in
        let tmpUrl = try! FileManager.default.url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: zipUrl,
            create: true
        ).appendingPathComponent(zipFileName)
        try! FileManager.default.moveItem(at: zipUrl, to: tmpUrl)
        archiveUrl = tmpUrl
    }
    return archiveUrl
}
