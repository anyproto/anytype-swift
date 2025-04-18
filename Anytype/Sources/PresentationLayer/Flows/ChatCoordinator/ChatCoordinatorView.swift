import SwiftUI

struct ChatCoordinatorView: View {
    
    @StateObject private var model: ChatCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.chatActionProvider) private var chatActionProvider
    
    init(data: ChatCoordinatorData) {
        self._model = StateObject(wrappedValue: ChatCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        ChatView(spaceId: model.spaceId, chatId: model.chatId, output: model)
            .attachSpaceLoadingContainer(spaceId: model.spaceId)
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .sheet(item: $model.objectToMessageSearchData) {
                ObjectSearchWithMetaCoordinatorView(data: $0)
            }
            .sheet(item: $model.showEmojiData) {
                MessageReactionPickerView(data: $0)
            }
            .anytypeSheet(isPresented: $model.showSyncStatusInfo) {
                SyncStatusInfoView(spaceId: model.spaceId)
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
            .sheet(item: $model.linkToObjectData) {
                LinkToObjectSearchView(data: $0, showEditorScreen: { _ in })
            }
            .sheet(item: $model.participantsReactionData) {
                MessageParticipantsReactionView(data: $0)
            }
            .photosPicker(isPresented: $model.showPhotosPicker, selection: $model.photosItems)
            .fileImporter(
                isPresented: $model.showFilesPicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: true
            ) { result in
                model.fileImporterFinished(result: result)
            }
            .safariSheet(url: $model.safariUrl)
            .fullScreenCover(item: $model.cameraData) {
                SimpleCameraView(data: $0)
            }
            .sheet(item: $model.newLinkedObject) {
                ChatCreateObjectCoordinatorView(data: $0)
            }
            .anytypeSheet(item: $model.inviteLinkData) {
                InviteLinkCoordinatorView(data: $0)
            }
            .onChange(of: model.photosItems) { _ in
                model.photosPickerFinished()
            }
    }
}
