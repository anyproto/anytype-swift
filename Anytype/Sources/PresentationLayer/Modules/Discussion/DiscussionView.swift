import SwiftUI

struct DiscussionView: View {
    
    @StateObject private var model: DiscussionViewModel
    
    init(objectId: String, spaceId: String, chatId: String, output: (any DiscussionModuleOutput)?) {
        self._model = StateObject(wrappedValue: DiscussionViewModel(objectId: objectId, spaceId: spaceId, chatId: chatId, output: output))
    }
    
    var body: some View {
        DiscussionSpacingContainer {
            DiscussionScrollView(position: $model.scrollViewPosition) {
                LazyVStack(spacing: 12) {
                    // TODO: Implement pagination
                    Button {
                        model.loadNextPage()
                    } label: {
                        Text("Load next page")
                    }

                    ForEach(model.mesageBlocks, id: \.id) {
                        MessageView(data: $0, output: model)
                    }
                }
                .padding(.vertical, 16)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                inputPanel
            }
        }
        .onAppear() {
            model.loadNextPage()
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
