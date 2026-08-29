import SwiftUI
import AnytypeCore
import Services


struct SpaceHubCoordinatorView: View {
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    @State private var model = SpaceHubCoordinatorViewModel()
    
    @Namespace private var namespace
    
    var body: some View {
        content
            .onAppear {
                model.keyboardDismiss = keyboardDismiss
                model.dismissAllPresented = dismissAllPresented
            }
            .onChange(of: model.navigationPath) { model.onPathChange() }
        
            .taskWithMemoryScope { await model.setup() }
            .handleSharingTip()
            .updateShortcuts(spaceId: model.fallbackSpaceId)
            .snackbar(toastBarData: $model.toastBarData)
            
            .sheet(item: $model.showGalleryImport) { data in
                GalleryInstallationCoordinatorView(data: data)
            }
            .sheet(isPresented: $model.showSpaceManager) {
                SpacesManagerView()
            }
            .sheet(item: $model.membershipDeepLinkData) { data in
                MembershipCoordinator(initialTierId: data.tierId, initialCode: data.code)
            }
            .sheet(item: $model.membershipNameFinalizationData) {
                MembershipNameFinalizationView(tier: $0)
            }
            .sheet(item: $model.showGlobalSearchData) {
                GlobalSearchView(data: $0)
            }
            .anytypeSheet(item: $model.spaceJoinData) {
                SpaceJoinView(data: $0, onManageSpaces: {
                    model.onManageSpacesSelected()
                }, onJoinedSpace: { spaceId, spaceType in
                    model.onSpaceJoined(spaceId: spaceId, spaceType: spaceType)
                })
            }
            .anytypeSheet(item: $model.userWarningAlert, dismissOnBackgroundView: false) {
                UserWarningAlertCoordinatorView(alert: $0)
            }
            .anytypeSheet(isPresented: $model.showObjectIsNotAvailableAlert) {
                ObjectIsNotAvailableAlert()
            }
            .anytypeSheet(item: $model.profileData) {
                ProfileView(info: $0)
                    .pageNavigation(model.pageNavigation)
            }
            .anytypeSheet(item: $model.spaceProfileData) {
                SpaceProfileView(info: $0)
            }
            .safariBookmarkObject($model.bookmarkScreenData) {
                model.onOpenBookmarkAsObject($0)
            }
            .sheet(item: $model.spaceCreateData) {
                SpaceCreateCoordinatorView(data: $0)
            }
            .sheet(isPresented: $model.showGroupChannelCreate) {
                GroupChannelCreateCoordinatorView()
            }
            .anytypeSheet(isPresented: $model.showSharedChannelLimit) {
                SharedChannelLimitView(
                    sharedSpacesLimit: model.sharedChannelLimit,
                    onUpgrade: { model.onSharedChannelLimitUpgrade() },
                    onManageChannels: { model.onSharedChannelLimitManageChannels() }
                )
            }
            .membershipUpgrade(reason: $model.membershipUpgradeReason)
            .sheet(item: $model.chatCreateData) { data in
                ChatCreateView(data: data)
                    .pageNavigation(model.pageNavigation)
            }
            .anytypeSheet(item: $model.bookmarkCreateData) { data in
                BookmarkCreateView(data: data)
                    .pageNavigation(model.pageNavigation)
            }
            .qrCodeScanner(shouldScan: $model.shouldScanQrCode)
            .sheet(isPresented: $model.showSharingExtension) {
                SharingExtensionCoordinatorView()
            }
            .sheet(isPresented: $model.showAppSettings) {
                SettingsCoordinatorView()
                    .pageNavigation(model.pageNavigation)
            }
        
            // load photos
            .photosPicker(isPresented: $model.showPhotosPicker, selection: $model.photosItems)
            .onChange(of: model.photosItems) {
                model.photosPickerFinished()
            }
        
            // load from camera
            .cameraAccessFullScreenCover(item: $model.cameraData) {
                SimpleCameraView(data: $0)
            }
            
            // load files
            .fileImporter(
                isPresented: $model.showFilesPicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: true
            ) { result in
                model.fileImporterFinished(result: result)
            }

            // widgets overlay
            .fullScreenCover(item: $model.overlayWidgetsData) { data in
                SearchOverlayHost(model: model, item: AnyHashable(data), content: HomeWidgetsCoordinatorView(data: data, context: .overlay))
                    .pageNavigation(model.pageNavigation)
                    .navigationZoomTransition(sourceID: "widgetsOverlay", in: namespace)
            }
            .onChange(of: model.overlayWidgetsData) { old, new in
                if new == nil {
                    model.onWidgetsOverlayDismissed(old)
                }
            }
    }
    
    private func searchOverlayHost(for item: some Hashable, @ViewBuilder content: () -> some View) -> some View {
        SearchOverlayHost(model: model, item: AnyHashable(item), content: content())
    }

    private var content: some View {
        ZStack {
            Color.Background.primary

            HomeBottomPanelContainer(
                path: $model.navigationPath,
                content: {
                    AnytypeNavigationView(path: $model.navigationPath, pathChanging: $model.pathChanging) { builder in
                        builder.appendBuilder(for: HomeWidgetData.self) { data in
                            searchOverlayHost(for: data) {
                                HomeWidgetsCoordinatorView(data: data, context: .navigation)
                            }
                        }
                        builder.appendBuilder(for: EditorScreenData.self) { data in
                            searchOverlayHost(for: data) {
                                EditorCoordinatorView(data: data)
                            }
                        }
                        builder.appendBuilder(for: SpaceHubNavigationItem.self) { item in
                            searchOverlayHost(for: item) {
                                SpaceHubView(output: model)
                            }
                        }
                        builder.appendBuilder(for: SpaceChatCoordinatorData.self) { data in
                            searchOverlayHost(for: data) {
                                SpaceChatCoordinatorView(data: data)
                            }
                        }
                        // Wrap here instead of inside ChatCoordinatorView to avoid nesting
                        // SpaceLoadingContainerView (see comment in SpaceLoadingContainerView.swift)
                        builder.appendBuilder(for: ChatCoordinatorData.self) { data in
                            searchOverlayHost(for: data) {
                                SpaceLoadingContainerView(spaceId: data.spaceId, showBackground: true) { _ in
                                    ChatCoordinatorView(data: data)
                                }
                            }
                        }
                        builder.appendBuilder(for: DiscussionCoordinatorData.self) { data in
                            searchOverlayHost(for: data) {
                                SpaceLoadingContainerView(spaceId: data.spaceId, showBackground: true) { _ in
                                    DiscussionCoordinatorView(data: data)
                                }
                            }
                        }
                        builder.appendBuilder(for: SpaceInfoScreenData.self) { data in
                            switch data {
                            case .settings(let spaceId):
                                SpaceSettingsCoordinator(spaceId: spaceId)
                            case .typeLibrary(let spaceId):
                                ObjectTypesLibraryView(spaceId: spaceId)
                            case .propertiesLibrary(let spaceId):
                                ObjectPropertiesLibraryView(spaceId: spaceId)
                            }
                        }
                     }
                },
                bottomPanel: {
                    if let spaceInfo = model.spaceInfo, !model.hidesBottomPanelForSearch {
                        HomeBottomNavigationPanelView(homePath: model.navigationPath, info: spaceInfo, output: model)
                    }
                }
            )

            NotificationCoordinatorView()
        }
        .widgetsAnimationNamespace(namespace)
        .animation(.easeInOut, value: model.spaceInfo)
        .pageNavigation(model.pageNavigation)
        .chatActionProvider($model.chatProvider)
    }
}

// Hosts the search overlay inside the screen it was opened over, so pushed
// results stack above it in the navigation hierarchy and an interactive pop
// reveals the open search as part of that screen - state, scroll and field
// intact, no transition of its own on return. Must be a View (not a builder
// function) so the model reads in body are observation-tracked.
private struct SearchOverlayHost<Content: View>: View {

    let model: SpaceHubCoordinatorViewModel
    let item: AnyHashable
    let content: Content

    var body: some View {
        ZStack {
            content
            if let searchData = model.searchOverlayData, model.searchOverlayOriginItem == item {
                UnifiedSearchView(data: searchData)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: model.searchOverlayData.isNotNil)
    }
}

#Preview {
    SpaceHubCoordinatorView()
}
