import SwiftUI

struct SharingExtensionView: View {
    
    @StateObject private var model: SharingExtensionViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(output: (any SharingExtensionModuleOutput)?) {
        self._model = StateObject(wrappedValue: SharingExtensionViewModel(output: output))
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            DragIndicator()
            ModalNavigationHeader(title: Loc.Sharing.title)
            
            if model.withoutSpaceState {
                withoutSpace
            } else {
                content
            }
        }
        .task {
            await model.onAppear()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
        .disabled(model.sendInProgress)
        .onChange(of: model.searchText) { _ in
            model.search()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        SearchBar(
            text: $model.searchText,
            focused: false,
            placeholder: Loc.search,
            shouldShowDivider: false
        )
        ZStack(alignment: .bottom) {
            listView
                .safeAreaInset(edge: .bottom) {
                    Spacer.fixedHeight(150)
                }
                .scrollDismissesKeyboard(.immediately)
            
                bottomPanel
        }
    }
    
    private var listView: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(model.spaces) { space in
                    SharingExtensionSpaceView(
                        icon: space.objectIconImage,
                        title: space.title,
                        isSelected: model.selectedSpace?.id == space.id
                    )
                    .onTapGesture {
                        model.onTapSpace(space)
                    }
                }
            }
            if let debugItems = model.debugInfo?.items {
                Section(header: Text(Loc.Debug.info)) {
                    ForEach(0..<debugItems.count, id: \.self) { index in
                        SharingExtensionDebugView(
                            index: index,
                            mimeTypes: debugItems[index].mimeTypes
                        )
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var bottomPanel: some View {
        if model.selectedSpace != nil {
            SharingExtensionBottomPanel(
                comment: $model.comment,
                showComment: true,
                commentLimit: model.commentLimit,
                commentWarningLimit: model.commentWarningLimit) {
                    try await model.onTapSend()
                }
        }
    }
    
    private var withoutSpace: some View {
        EmptyStateView(title: Loc.thereAreNoSpacesYet, style: .withImage)
    }
}

#Preview {
    MockView {
        SharingExtensionView(output: nil)
    }
}
