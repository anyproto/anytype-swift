import SwiftUI

struct DiscussionCoordinatorView: View {
    
    @StateObject private var model: DiscussionCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(data: EditorDiscussionObject) {
        self._model = StateObject(wrappedValue: DiscussionCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        chatView
            .onAppear {
                model.pageNavigation = pageNavigation
            }
            .task {
                await model.startHandleDetails()
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
    }
    
    @ViewBuilder
    private var chatView: some View {
        if let chatId = model.chatId {
            DiscussionView(objectId: model.objectId, spaceId: model.spaceId, chatId: chatId, output: model)
        } else {
            AnytypeDivider()
        }
    }
}

#Preview {
    DiscussionCoordinatorView(data: EditorDiscussionObject(objectId: "", spaceId: ""))
}
