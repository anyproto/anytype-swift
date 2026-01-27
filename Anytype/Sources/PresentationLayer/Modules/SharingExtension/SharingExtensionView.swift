import SwiftUI

struct SharingExtensionView: View {

    @State private var model: SharingExtensionViewModel
    @Environment(\.dismiss) private var dismiss

    var suggestedSpaceId: String?

    init(output: (any SharingExtensionModuleOutput)?, suggestedSpaceId: String?) {
        self.suggestedSpaceId = suggestedSpaceId
        self._model = State(initialValue: SharingExtensionViewModel(output: output))
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            DragIndicator()
            NavigationHeader(title: Loc.Sharing.title, navigationButtonType: .none)
            
            if model.withoutSpaceState {
                withoutSpace
            } else {
                content
            }
        }
        .task {
            await model.onAppear()
        }
        .onChange(of: model.dismiss) {
            dismiss()
        }
        .disabled(model.sendInProgress)
        .onChange(of: suggestedSpaceId) { _, spaceId in
            if let spaceId {
                model.setSuggestedSpaceId(spaceId)
            }
        }
        .onChange(of: model.searchText) {
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
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(model.spaces) { space in
                        Button {
                            model.onTapSpace(space)
                        } label: {
                            SharingExtensionSpaceView(
                                icon: space.objectIconImage,
                                title: space.title,
                                isSelected: model.selectedSpace?.id == space.id
                            )
                        }
                        .buttonStyle(.plain)
                        .id(space.id)
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
            .onChange(of: model.scrollToSpaceId) { _, spaceId in
                guard let spaceId else { return }
                model.scrollToSpaceId = nil
                withAnimation {
                    proxy.scrollTo(spaceId, anchor: .center)
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
        SharingExtensionView(output: nil, suggestedSpaceId: nil)
    }
}
