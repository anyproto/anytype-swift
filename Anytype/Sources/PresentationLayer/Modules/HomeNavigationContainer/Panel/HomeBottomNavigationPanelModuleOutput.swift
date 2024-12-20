import Foundation

@MainActor
protocol HomeBottomNavigationPanelModuleOutput: AnyObject {
    func onSearchSelected()
    func onCreateObjectSelected(screenData: EditorScreenData)
    func onProfileSelected()
    func onWidgetsSelected()
    func onForwardSelected()
    func onBackwardSelected()
    func onPickTypeForNewObjectSelected()
    func onSpaceHubSelected()
}
