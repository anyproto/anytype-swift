import SwiftUI

struct DiscussionView: View {
    
    @StateObject private var model: DiscussionViewModel
    
    init(objectId: String, spaceId: String, chatId: String, output: (any DiscussionModuleOutput)?) {
        self._model = StateObject(wrappedValue: DiscussionViewModel(objectId: objectId, spaceId: spaceId, chatId: chatId, output: output))
    }
    
    var body: some View {
        DiscussionSpacingContainer {
            DiscussionCollectionView(items: model.mesageBlocks, diffApply: model.messagesScrollUpdate) {
                MessageView(data: $0, output: model)
//                    .task {
//                        do {
//                            print("start started")
//                            try await Task.sleep(seconds: 100000)
//                        } catch {
//                            print("task error \(error)")
//                        }
//                    }
//                    .onAppear {
//                        model.didShowMessage(data: $0)
//                    }
//                    .onDisappear {
//                        model.didHideMessage(data: $0)
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
