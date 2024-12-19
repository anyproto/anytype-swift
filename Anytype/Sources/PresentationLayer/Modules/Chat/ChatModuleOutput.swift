import Foundation

@MainActor
protocol ChatModuleOutput: AnyObject {
    func onLinkObjectSelected(data: BlockObjectSearchData)
    func didSelectAddReaction(messageId: String)
    func didLongTapOnReaction(data: MessageParticipantsReactionData)
    func didSelectLinkToObject(data: LinkToObjectSearchModuleData)
    func onObjectSelected(screenData: EditorScreenData)
    func onPhotosPickerSelected(data: ChatPhotosPickerData)
    func onFilePickerSelected(data: ChatFilesPickerData)
    func onShowCameraSelected(data: SimpleCameraData)
    func onMediaFileSelected(startAtIndex: Int, items: [any PreviewRemoteItem])
    func onUrlSelected(url: URL)
}
