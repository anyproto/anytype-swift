import UIKit

class AppearanceService {
    let assets = AssetsStorage.Local()
    let schemes = Schemes()

    func resetToDefaults() {
        if let scheme = schemes.scheme(for: Schemes.Global.SwiftUI.BaseText.self) {
            scheme.foregroundColor = assets.colors.main.yellow.value
            scheme.font = .body
            scheme.fontWeight = .medium
        }

        if let scheme = schemes.scheme(for: Schemes.Global.Appearance.BaseNavigationBar.self) {
            scheme.barTintColor = UIColor.green
        }
    }
}
