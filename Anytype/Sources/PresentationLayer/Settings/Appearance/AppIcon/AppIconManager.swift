import Foundation
import UIKit
import AnytypeCore


@MainActor
final class AppIconManager {
    
    static let shared = AppIconManager()
    
    var currentIcon: AppIcon {
        AppIcon.allCases.first { $0.iconName == UIApplication.shared.alternateIconName } ?? .standart
    }
    
    func setIcon(_ appIcon: AppIcon, completion: ((Bool) -> Void)? = nil) {
        guard currentIcon != appIcon, UIApplication.shared.supportsAlternateIcons else { return }
        
        UIApplication.shared.setAlternateIconName(appIcon.iconName) { error in
            if let error = error {
                anytypeAssertionFailure("Error setting alternate icon: \(error.localizedDescription))", info: ["name": appIcon.iconName ?? ""])
            }
            completion?(error != nil)
        }
    }
}
