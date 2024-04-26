import Foundation

@MainActor
protocol HomeBottomNavigationPanelModuleOutput: AnyObject {
    func onSearchSelected()
    func onCreateObjectSelected(screenData: EditorScreenData)
    func onProfileSelected()
    func onHomeSelected()
    func onForwardSelected()
    func onBackwardSelected()
    func onCreateObjectWithTypeSelected()
}
