import Foundation

@MainActor
protocol SettingsAppearanceModuleOutput: AnyObject {
    func onWallpaperChangeSelected()
}
