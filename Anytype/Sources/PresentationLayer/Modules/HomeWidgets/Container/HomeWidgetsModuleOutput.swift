import Foundation

@MainActor
protocol HomeWidgetsModuleOutput: AnyObject, CommonWidgetModuleOutput {
    func onSpaceSelected()
    func onCreateWidgetSelected(context: AnalyticsWidgetContext)
    func onCreateObjectType()
}
