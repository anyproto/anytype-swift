import Foundation

@MainActor
protocol HomeBottomNavigationPanelModuleOutput: AnyObject {
    func onSearchSelected()
    func onCreateObjectSelected(screenData: EditorScreenData)
    func onForwardSelected()
    func onBackwardSelected()
    func onPickTypeForNewObjectSelected()
}
