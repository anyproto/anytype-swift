import Foundation

@MainActor
protocol HomeBottomNavigationPanelModuleOutput: AnyObject {
    func onSearchSelected()
    func onCreateObjectSelected(screenData: ScreenData)
    func onForwardSelected()
    func onBackwardSelected()
    func onPickTypeForNewObjectSelected()
    func onMembersSelected()
    func onShareSelected()
    func onAddAttachmentToSpaceLevelChat(attachment: ChatLinkObject)
}
