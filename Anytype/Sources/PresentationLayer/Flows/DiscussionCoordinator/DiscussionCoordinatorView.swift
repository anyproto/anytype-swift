import SwiftUI

struct DiscussionCoordinatorView: View {

    @State private var model: DiscussionCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.chatActionProvider) private var chatActionProvider
    @Environment(\.dismiss) private var dismiss

    init(data: DiscussionCoordinatorData) {
        self._model = State(wrappedValue: DiscussionCoordinatorViewModel(data: data))
    }

    var body: some View {
        content
    }

    private var content: some View {
        DiscussionView(spaceId: model.spaceId, discussionId: model.discussionId, output: model, settingsOutput: model)
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .onChange(of: model.dismiss) {
                dismiss()
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
            .cameraAccessFullScreenCover(item: $model.cameraData) {
                SimpleCameraView(data: $0)
            }
            .sheet(item: $model.newLinkedObject) {
                ChatCreateObjectCoordinatorView(data: $0)
            }
            .anytypeSheet(item: $model.pushNotificationsAlertData) {
                PushNotificationsAlertView(data: $0)
            }
            .anytypeSheet(isPresented: $model.showDisabledPushNotificationsAlert){
                DisabledPushNotificationsAlertView()
            }
            .sheet(item: $model.spaceShareData) { data in
                SpaceShareCoordinatorView(data: data)
            }
            .anytypeSheet(item: $model.qrCodeInviteLink) {
                QrCodeView(title: Loc.joinSpace, data: $0.absoluteString, analyticsType: .inviteSpace, route: .chat)
            }
            .onChange(of: model.photosItems) {
                model.photosPickerFinished()
            }
    }
}
