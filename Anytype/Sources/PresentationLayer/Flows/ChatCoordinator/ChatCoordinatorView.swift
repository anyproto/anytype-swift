import SwiftUI

struct ChatCoordinatorView: View {
    
    @StateObject private var model: ChatCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: ChatCoordinatorData) {
        self._model = StateObject(wrappedValue: ChatCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        ChatView(spaceId: model.spaceId, chatId: model.chatId, output: model)
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .sheet(item: $model.objectToMessageSearchData) {
                BlockObjectSearchView(data: $0)
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
            .photosPicker(isPresented: $model.showPhotosPicker, selection: $model.photosItems)
            .fileImporter(
                isPresented: $model.showFilesPicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: true
            ) { result in
                model.fileImporterFinished(result: result)
            }
            .onChange(of: model.photosItems) { _ in
                model.photosPickerFinished()
            }
    }
}
