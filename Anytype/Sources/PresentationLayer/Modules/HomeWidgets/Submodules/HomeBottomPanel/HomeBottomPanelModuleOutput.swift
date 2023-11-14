import Foundation

// TODO: Refactoring this
@MainActor
protocol HomeBottomPanelModuleOutput: AnyObject {
    func onCreateWidgetSelected(context: AnalyticsWidgetContext)
    func onSearchSelected()
    func onCreateObjectSelected(screenData: EditorScreenData)
    func onProfileSelected()
    func onCreateObjectWithTypeSelected()
}
