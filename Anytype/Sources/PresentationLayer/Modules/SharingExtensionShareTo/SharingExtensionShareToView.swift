import SwiftUI
import DesignKit

struct SharingExtensionShareToData: Hashable, Identifiable {
    let spaceId: String
    var suggestedChatId: String?

    var id: Int { hashValue }
}

struct SharingExtensionShareToView: View {

    @State private var model: SharingExtensionShareToViewModel
    @Environment(\.dismiss) private var dismiss

    init(data: SharingExtensionShareToData, output: (any SharingExtensionShareToModuleOutput)?) {
        self._model = State(initialValue: SharingExtensionShareToViewModel(data: data, output: output))
    }
    
    var body: some View {
        VStack {
            DragIndicator()
            NavigationHeader(title: model.title, navigationButtonType: .none)
            SearchBar(
                text: $model.searchText,
                focused: false,
                placeholder: Loc.search,
                shouldShowDivider: false
            )
            ZStack(alignment: .bottom) {
                list
                bottomPanel
            }
        }
        .task(id: model.searchText) {
            await model.search()
        }
        .onChange(of: model.dismiss) {
            dismiss()
        }
        .disabled(model.sendInProgress)
    }
    
    private var list: some View {
        PlainList {
            ListSectionHeaderView(title: Loc.Sharing.ObjectList.title)
                .newDivider()
                .padding(.horizontal, 16)
            chatSection
            objectSection
        }
        .safeAreaInset(edge: .bottom) {
            Spacer.fixedHeight(150)
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private var chatSection: some View {
        switch model.chatDisplayMode {
        case .sendToChat(let data):
            Button {
                model.onTapChat()
            } label: {
                SharingExtensionsChatRow(data: data)
                    .fixTappableArea()
            }
            .buttonStyle(.plain)
        case .individualChats(let rows):
            ForEach(rows) { data in
                Button {
                    model.onTapCell(data: data)
                } label: {
                    SharingExtensionsShareRow(data: data)
                        .fixTappableArea()
                }
                .buttonStyle(.plain)
            }
        case nil:
            EmptyView()
        }
    }
    
    private var objectSection: some View {
        ForEach(model.rows) { data in
            Button {
                model.onTapCell(data: data)
            } label: {
                SharingExtensionsShareRow(data: data)
                    .fixTappableArea()
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private var bottomPanel: some View {
        SharingExtensionBottomPanel(
            comment: $model.comment,
            showComment: model.chatSelected,
            commentLimit: model.commentLimit,
            commentWarningLimit: model.commentWarningLimit) {
                try await model.onTapSend()
            }
    }
}

#Preview {
    MockView {
        SharingExtensionShareToView(data: SharingExtensionShareToData(spaceId: "1"), output: nil)
    }
}
