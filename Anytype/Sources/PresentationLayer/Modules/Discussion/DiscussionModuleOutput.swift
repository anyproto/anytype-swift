import Foundation

@MainActor
protocol DiscussionModuleOutput: AnyObject {
    func onLinkObjectSelected(data: BlockObjectSearchData)
    func didSelectAddReaction(messageId: String)
    func onSyncStatusSelected()
    func onSettingsSelected()
    func onIconSelected()
    func didSelectLinkToObject(data: LinkToObjectSearchModuleData)
    func onObjectSelected(screenData: EditorScreenData)
    func onPhotosPickerSelected(data: DiscussionPhotosPickerData)
    func onFilePickerSelected(data: DiscussionFilesPickerData)
}
