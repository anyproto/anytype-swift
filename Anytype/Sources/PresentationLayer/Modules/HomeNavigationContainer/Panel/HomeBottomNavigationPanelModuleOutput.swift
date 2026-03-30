import Foundation

@MainActor
protocol HomeBottomNavigationPanelModuleOutput: AnyObject {
    func onCreateObjectSelected(screenData: ScreenData)
    func onAddMediaSelected(spaceId: String)
    func onCameraSelected(spaceId: String)
    func onAddFilesSelected(spaceId: String)
    func onShowWidgetsOverlay(spaceId: String)
}
