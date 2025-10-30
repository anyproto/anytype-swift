import SwiftUI
import AnytypeCore
import DesignKit


struct SpaceHubView: View {
    @State private var model: SpaceHubViewModel
    
    private var namespace: Namespace.ID
    
    init(output: (any SpaceHubModuleOutput)?, namespace: Namespace.ID) {
        _model = State(wrappedValue: SpaceHubViewModel(output: output))
        self.namespace = namespace
    }
    
    var body: some View {
        content
            .onAppear { model.onAppear() }
            .taskWithMemoryScope { await model.startSubscriptions() }
            .task(item: model.spaceMuteData) { data in
                await model.pushNotificationSetSpaceMode(data: data)
            }
            .homeBottomPanelHidden(true)
            .anytypeSheet(item: $model.spaceToDelete) { spaceId in
                SpaceDeleteAlert(spaceId: spaceId.value)
            }
            .handleChatCreationTip()
            .accessibilityLabel("SpaceHub")
    }
    
    @ViewBuilder
    private var content: some View {
        Group {
            if model.dataLoaded {
                spacesView()
            } else {
                EmptyView() // Do not show empty state view if we do not receive data yet
            }
            
            Spacer()
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func spacesView() -> some View {
        NavigationStack {
            SpaceHubList(model: model)
//            Group {
//                if model.filteredSpaces.isEmpty && model.searchText.isEmpty {
//                    emptyStateView
//                } else if model.filteredSpaces.isNotEmpty {
//                    scrollView
//                } else {
//                    SpaceHubSearchEmptySpaceView()
//                }
//            }
            .navigationTitle(Loc.myChannels)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarItems }
            .searchable(text: $model.searchText)
            .onChange(of: model.searchText) {
                model.searchTextUpdated()
            }
        }.tint(Color.Text.secondary)
    }
    
    private var toolbarItems: some ToolbarContent {
        SpaceHubToolbar(
            showLoading: model.showLoading,
            profileIcon: model.profileIcon,
            notificationsDenied: model.notificationsDenied,
            namespace: namespace,
            onTapCreateSpace: {
                model.onTapCreateSpace()
            },
            onTapSettings: {
                model.onTapSettings()
            }
        )
    }
}

#Preview {
    @Previewable @Namespace var namespace
    SpaceHubView(output: nil, namespace: namespace)
}
