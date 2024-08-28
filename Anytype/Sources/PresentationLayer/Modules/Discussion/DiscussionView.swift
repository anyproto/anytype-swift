import SwiftUI

struct DiscussionView: View {
    
    @StateObject private var model: DiscussionViewModel
    
    init(objectId: String, spaceId: String, output: (any DiscussionModuleOutput)?) {
        self._model = StateObject(wrappedValue: DiscussionViewModel(objectId: objectId, spaceId: spaceId, output: output))
    }
    
    var body: some View {
        DiscussionSpacingContainer {
            DiscussionScrollView(position: $model.scrollViewPosition) {
                LazyVStack(spacing: 12) {
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
        .task {
            await model.startHandleDetails()
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
    DiscussionView(objectId: "", spaceId: "", output: nil)
}
