import Foundation

@MainActor
protocol HomeWidgetsModuleOutput: AnyObject {
    func onOldHomeSelected()
    func onCreateWidgetSelected()
    func onSpaceIconChangeSelected(objectId: String)
}
