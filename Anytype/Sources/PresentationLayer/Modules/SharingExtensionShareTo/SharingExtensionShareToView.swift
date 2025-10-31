import SwiftUI
import DesignKit

struct SharingExtensionShareToData: Hashable, Identifiable {
    let spaceId: String
    
    var id: Int { hashValue }
}

struct SharingExtensionShareToView: View {
    
    @StateObject private var model: SharingExtensionShareToViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: SharingExtensionShareToData, output: (any SharingExtensionShareToModuleOutput)?) {
        self._model = StateObject(wrappedValue: SharingExtensionShareToViewModel(data: data, output: output))
    }
    
    var body: some View {
        VStack {
            DragIndicator()
            ModalNavigationHeader(title: model.title)
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
            if let chatRow = model.chatRow {
                SharingExtensionsChatRow(data: chatRow)
                    .fixTappableArea()
                    .onTapGesture {
                        model.onTapChat()
                    }
            }
            ForEach(model.rows) { data in
                SharingExtensionsShareRow(data: data)
                    .fixTappableArea()
                    .onTapGesture {
                        model.onTapCell(data: data)
                    }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Spacer.fixedHeight(150)
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private var bottomPanel: some View {
        SharingExtensionBottomPanel(
            comment: $model.comment,
            showComment: model.chatRowSelected,
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
