import Foundation

@MainActor
protocol HomeBottomPanelModuleOutput: AnyObject {
    func onCreateWidgetSelected()
    func onSearchSelected()
}
