import SwiftUI

struct DiscussionView: View {
    
    @StateObject private var model: DiscussionViewModel
    
    init(objectId: String, spaceId: String, output: DiscussionModuleOutput?) {
        self._model = StateObject(wrappedValue: DiscussionViewModel(objectId: objectId, spaceId: spaceId, output: output))
    }
    
    var body: some View {
        DiscussionSpacingContainer {
            ScrollView {
                VStack {
                    ForEach(model.mesageBlocks, id: \.id) {
                        MessageView(block: $0)
                    }
                    HStack {
                        Spacer()
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                inputPanel
            }
        }
        .task {
            await model.subscribeForParticipants()
        }
        .task {
            await model.subscribeForBlocks()
        }
    }
    
    private var inputPanel: some View {
        VStack(spacing: 0) {
            DiscussionLinkInputViewContainer(objects: model.linkedObjects) {
                model.onTapRemoveLinkedObject(details: $0)
            }
            DiscusionInput {
                model.onTapAddObjectToMessage()
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
