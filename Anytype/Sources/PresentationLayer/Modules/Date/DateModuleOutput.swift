import Foundation

@MainActor
protocol DateModuleOutput: AnyObject {
    func onSyncStatusTap()
    func onObjectTap(data: EditorScreenData)
}
