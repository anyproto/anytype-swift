import Foundation
import UIKit
import AnytypeCore


@MainActor
final class AppIconManager {
    
    static let shared = AppIconManager()
    
    var currentIcon: AppIcon {
        AppIcon.allCases.first { $0.iconName == UIApplication.shared.alternateIconName } ?? .standart
    }
    
    func setIcon(_ appIcon: AppIcon, completion: (@Sendable @MainActor (Bool) -> Void)? = nil) {
        guard currentIcon != appIcon, UIApplication.shared.supportsAlternateIcons else { return }
        
        UIApplication.shared.setAlternateIconName(appIcon.iconName) { error in
            if let error = error {
                anytypeAssertionFailure("Error setting alternate icon: \(error.localizedDescription))", info: ["name": appIcon.iconName ?? ""])
            }
            Task { @MainActor in
                completion?(error != nil)
            }
        }
    }
    
    // Delete after release 10
    func migrateIcons() {
        guard UIApplication.shared.alternateIconName.isNotNil else { return }
        
        if AppIcon.allCases.first(where: { $0.iconName == UIApplication.shared.alternateIconName }).isNil {
            UIApplication.shared.setAlternateIconName(nil)
        }
    }
}
