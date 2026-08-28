import SwiftUI
import AnytypeCore
import DesignKit


struct SpaceHubView: View {
    @State private var model: SpaceHubViewModel

    init(output: (any SpaceHubModuleOutput)?) {
        _model = State(wrappedValue: SpaceHubViewModel(output: output))
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
            .anytypeSheet(item: $model.spaceToLeave) { spaceId in
                SpaceLeaveAlert(spaceId: spaceId.value)
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
    
    private var isEmptyState: Bool {
        model.filteredSpaces.isEmpty && model.searchText.isEmpty
    }

    @ViewBuilder
    private func spacesView() -> some View {
        NavigationStack {
            SpaceHubList(model: model)
                .navigationTitle(Loc.myChannels)
                .scrollEdgeEffectStyleIOS26(.soft, for: .top)
                .toolbar { toolbarItems }
                .if(!isEmptyState) { view in
                    view.searchable(text: $model.searchText)
                }
                .onChange(of: model.searchText) {
                    model.searchTextUpdated()
                }
        }.tint(Color.Text.secondary)
    }
    
    private var toolbarItems: some ToolbarContent {
        SpaceHubToolbar(
            profileIcon: model.profileIcon,
            notificationsNotDetermined: model.notificationsNotDetermined,
            hideCreateButton: isEmptyState,
            quickCaptureEnabled: FeatureFlags.quickCapture,
            onTapCreatePersonalChannel: {
                model.onTapCreatePersonalChannel()
            },
            onTapCreateGroupChannel: {
                model.onTapCreateGroupChannel()
            },
            onTapJoinViaQrCode: {
                model.onTapJoinViaQrCode()
            },
            onTapSettings: {
                model.onTapSettings()
            },
            onTapQuickCapture: {
                model.onTapQuickCapture()
            }
        )
    }
}

#Preview {
    SpaceHubView(output: nil)
}
