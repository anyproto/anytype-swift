import Foundation

@MainActor
protocol HomeBottomPanelModuleOutput: AnyObject {
    func onCreateWidgetSelected(context: AnalyticsWidgetContext)
}
