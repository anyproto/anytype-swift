import Foundation

@MainActor
protocol PersonalizationModuleOutput: AnyObject {
    func onDefaultTypeSelected()
    func onWallpaperChangeSelected()
}
