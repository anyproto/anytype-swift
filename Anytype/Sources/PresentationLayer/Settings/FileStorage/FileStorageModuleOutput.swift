import Foundation

@MainActor
protocol FileStorageModuleOutput: AnyObject {
    func onClearCacheSelected()
}
