import Foundation

@MainActor
protocol HomeWidgetsModuleOutput: AnyObject, CommonWidgetModuleOutput {
    func onSpaceSelected()
}
