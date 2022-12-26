import Foundation

@MainActor
protocol HomeWidgetsModuleOutput: AnyObject {
    func onOldHomeSelected()
}
