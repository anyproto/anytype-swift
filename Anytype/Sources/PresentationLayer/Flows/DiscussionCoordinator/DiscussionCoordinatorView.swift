import SwiftUI

struct DiscussionCoordinatorView: View {
    
    @StateObject private var model: DiscussionCoordinatorViewModel
    
    init(data: EditorDiscussionObject) {
        self._model = StateObject(wrappedValue: DiscussionCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        chatView
            .sheet(item: $model.objectToMessageSearchData) {
                BlockObjectSearchView(data: $0)
            }
            .sheet(item: $model.showEmojiData) {
                MessageReactionPickerView(data: $0)
            }
            .task {
                await model.startHandleDetails()
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
