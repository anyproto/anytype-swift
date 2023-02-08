import Foundation

@MainActor
protocol HomeBottomPanelModuleOutput: AnyObject {
    func onCreateWidgetSelected()
    func onSearchSelected()
    func onCreateObjectSelected(screenData: EditorScreenData)
}
