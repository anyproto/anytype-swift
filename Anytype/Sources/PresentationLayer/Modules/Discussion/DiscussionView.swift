import SwiftUI

struct DiscussionView: View {
    
    @StateObject private var model: DiscussionViewModel
    
    init(objectId: String, spaceId: String, chatId: String, output: (any DiscussionModuleOutput)?) {
        self._model = StateObject(wrappedValue: DiscussionViewModel(objectId: objectId, spaceId: spaceId, chatId: chatId, output: output))
    }
    
    var body: some View {
        DiscussionSpacingContainer {
//            DiscussionScrollView(position: $model.scrollViewPosition) {
//                VStack(spacing: 12) {
//                    ForEach(model.mesageBlocks, id: \.id) {
//                        MessageView(data: $0, output: model)
//                    }
//                }
//                .padding(.vertical, 16)
//            }
            DiscussionCollectionView(items: model.mesageBlocks) {
                MessageView(data: $0, output: model)
//                    .onAppear {
//                        print("message view on appear")
//                    }
//                    .onDisappear {
//                        print("message view on disappear")
//                    }
            } scrollToBottom: {
                await model.scrollToBottom()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                inputPanel
            }
        }
        .task {
            await model.subscribeOnParticipants()
        }
        .throwingTask {
            try await model.subscribeOnMessages()
        }
    }
    
    private var inputPanel: some View {
        VStack(spacing: 0) {
            MessageLinkInputViewContainer(objects: model.linkedObjects) {
                model.onTapRemoveLinkedObject(details: $0)
            }
            DiscusionInput(text: $model.message) {
                model.onTapAddObjectToMessage()
            } onTapSend: {
                model.onTapSendMessage()
            }
        }
        .overlay(alignment: .top) {
            AnytypeDivider()
        }
    }
}

#Preview {
    DiscussionView(objectId: "", spaceId: "", chatId: "", output: nil)
}
