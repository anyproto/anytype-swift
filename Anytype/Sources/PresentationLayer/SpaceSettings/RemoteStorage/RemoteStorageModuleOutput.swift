import Foundation

@MainActor
protocol RemoteStorageModuleOutput: AnyObject {
    func onManageFilesSelected()
}
