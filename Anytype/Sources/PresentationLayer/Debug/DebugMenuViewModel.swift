import Foundation
import UIKit
import AnytypeCore

final class DebugMenuViewModel: ObservableObject {
    
    @Published private(set) var isRemovingRecoveryPhraseInProgress = false
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
