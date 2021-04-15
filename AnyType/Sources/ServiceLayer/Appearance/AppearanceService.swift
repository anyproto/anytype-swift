import SwiftUI


class AppearanceService {
    let schemes = Schemes()

    func resetToDefaults() {
        if let scheme = schemes.scheme(for: Schemes.Global.SwiftUI.BaseText.self) {
            scheme.foregroundColor = Color.yellow
            scheme.font = .body
            scheme.fontWeight = .medium
        }

        if let scheme = schemes.scheme(for: Schemes.Global.Appearance.BaseNavigationBar.self) {
            scheme.barTintColor = UIColor.green
        }
    }
}
