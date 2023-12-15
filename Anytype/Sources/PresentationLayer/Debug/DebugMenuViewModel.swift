import Foundation
import UIKit
import AnytypeCore
import Services

final class DebugMenuViewModel: ObservableObject {
    
    @Published private(set) var isRemovingRecoveryPhraseInProgress = false
    @Published var localStoreURL: URL?
    @Published private(set) var flags = [FeatureFlagSection]()
    
    init() {
        updateFlags()
    }
    
    func removeRecoveryPhraseFromDevice() {
        isRemovingRecoveryPhraseInProgress = true
        ServiceLocator.shared.authService().logout(removeData: false) { isSuccess in
            guard isSuccess else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            do {
                try ServiceLocator.shared.seedService().removeSeed()
                ServiceLocator.shared.applicationStateService().state = .auth
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
    
    func getLocalStoreData() {
        let debugService = DebugService()
        
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
