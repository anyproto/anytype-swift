import Foundation

@MainActor
protocol HomeBottomNavigationPanelModuleOutput: AnyObject {
    func onSearchSelected()
    func onCreateObjectSelected(screenData: ScreenData)
    func onPickTypeForNewObjectSelected()
    func onMembersSelected()
    func onShareSelected()
    func onAddMediaSelected(spaceId: String)
    func onCameraSelected(spaceId: String)
    func onAddFilesSelected(spaceId: String)
    func popToFirstInSpace()
    func onAddAttachmentToSpaceLevelChat(attachment: ChatLinkObject)
}
