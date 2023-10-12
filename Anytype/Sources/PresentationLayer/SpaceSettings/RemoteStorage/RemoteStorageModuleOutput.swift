import Foundation

@MainActor
protocol RemoteStorageModuleOutput: AnyObject {
    func onManageFilesSelected()
    func onLinkOpen(url: URL)
}
