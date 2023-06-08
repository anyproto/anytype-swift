import Foundation

@MainActor
protocol AboutModuleOutput: AnyObject {
    func onDebugMenuSelected()
}
