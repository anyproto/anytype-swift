import Foundation

@MainActor
protocol AboutModuleOutput: AnyObject {
    func onDebugMenuForAboutSelected()
}
