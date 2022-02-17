import Foundation
import UIKit
import AnytypeCore

final class AppIconManager {
    
    static let shared = AppIconManager()
    
    var currentIcon: AppIcon {
        AppIcon.allCases.first { $0.name == UIApplication.shared.alternateIconName } ?? .gradient
    }
    
    func setIcon(_ appIcon: AppIcon, completion: ((Bool) -> Void)? = nil) {
        guard currentIcon != appIcon, UIApplication.shared.supportsAlternateIcons else { return }
        
        UIApplication.shared.setAlternateIconName(appIcon.name) { error in
            if let error = error {
                anytypeAssertionFailure("Error setting alternate icon \(appIcon.name ?? ""): \(error.localizedDescription)", domain: .appIcon)
            }
            completion?(error != nil)
        }
    }
}
