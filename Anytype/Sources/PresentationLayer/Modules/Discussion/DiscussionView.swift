import SwiftUI

struct DiscussionView: View {
    
    @StateObject private var model: DiscussionViewModel
    
    init(spaceId: String, output: DiscussionModuleOutput?) {
        self._model = StateObject(wrappedValue: DiscussionViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        DiscussionSpacingContainer {
            ScrollView {
                VStack {
                    message("Message 1")
                    message("Message 2")
                    message("Message 3")
                    message("Message 4")
                    message("Message 5")
                    message("Message 6")
                    message("Message 7")
                    message("Message 8")
                    message("Message 9")
                    message("Message 10")
                    message("Message 11")
                    message("Message 12")
                    message("Message 13")
                    message("Message 14")
                    message("Message 15")
                    HStack {
                        Spacer()
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                inputPanel
            }
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
    
    private func message(_ text: String) -> some View {
        Text(text)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background(Color.gray)
            .cornerRadius(8)
    }
}

#Preview {
    DiscussionView(spaceId: "", output: nil)
}
