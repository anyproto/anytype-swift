import Foundation

@MainActor
protocol HomeBottomPanelModuleOutput: AnyObject {
    func onCreateWidgetSelected(context: AnalyticsWidgetContext)
    func onSearchSelected()
    func onCreateObjectSelected(screenData: EditorScreenData)
    func onSettingsSelected()
}
