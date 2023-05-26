import Foundation

@MainActor
protocol AboutModuleOutput: AnyObject {
    func onDebugMenuSelected()
    func onLinkOpen(url: URL)
}
