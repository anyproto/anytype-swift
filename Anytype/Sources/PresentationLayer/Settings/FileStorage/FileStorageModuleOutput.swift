import Foundation

@MainActor
protocol FileStorageModuleOutput: AnyObject {
    func onClearCacheSelected()
    func onManageFilesSelected()
    func onLinkOpen(url: URL)
}
