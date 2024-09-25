import SwiftUI
import AnytypeCore
import Services


struct SpaceHubCoordinatorView: View {
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    @StateObject private var model = SpaceHubCoordinatorViewModel()
    
    var body: some View {
        content
            .onAppear {
                model.keyboardDismiss = keyboardDismiss
                model.dismissAllPresented = dismissAllPresented
            }
            .onChange(of: model.navigationPath) { _ in model.onPathChange() }
            
            .if(FeatureFlags.swipeToSearch) {
                $0.simultaneousGesture(
                    DragGesture(minimumDistance: 30, coordinateSpace: .global)
                        .onChanged {
                            if $0.startLocation.y < 150 && $0.translation.height > 60 {
                                model.onSearchSelected()
                            }
                        }
                )
            }
        
            .task { await model.startHandleWorkspaceInfo() }
            .task { await model.setup() }
            .task { await model.startHandleAppActions() }
            
            .handleSpaceShareTip()
            .handleSharingTip()
            .handleSpaceHubTip()
            .updateShortcuts(spaceId: model.fallbackSpaceId)
            .snackbar(toastBarData: $model.toastBarData)
            
            .sheet(item: $model.sharingSpaceId) {
                ShareCoordinatorView(spaceId: $0.value)
            }
            .sheet(item: $model.showGalleryImport) { data in
                GalleryInstallationCoordinatorView(data: data)
            }
            .sheet(isPresented: $model.showSpaceManager) {
                SpacesManagerView()
            }
            .sheet(isPresented: $model.showSpaceShareTip) {
                SpaceShareTipView()
            }
            .sheet(item: $model.membershipTierId) { tierId in
                MembershipCoordinator(initialTierId: tierId.value)
            }
            .sheet(item: $model.showSpaceSwitchData) {
                SpaceSwitchCoordinatorView(data: $0)
            }
            .sheet(item: $model.membershipNameFinalizationData) {
                MembershipNameFinalizationView(tier: $0)
            }
            .sheet(item: $model.showGlobalSearchData) {
                GlobalSearchView(data: $0)
            }
            .sheet(item: $model.typeSearchForObjectCreationSpaceId) {
                model.typeSearchForObjectCreationModule(spaceId: $0.value)
            }
            .sheet(item: $model.showChangeSourceData) {
                WidgetChangeSourceSearchView(data: $0) {
                    model.onFinishChangeSource(screenData: $0)
                }
            }
            .sheet(item: $model.showChangeTypeData) {
                WidgetTypeChangeView(data: $0)
            }
            .sheet(item: $model.showCreateWidgetData) {
                CreateWidgetCoordinatorView(data: $0) {
                    model.onFinishCreateSource(screenData: $0)
                }
            }
            .sheet(item: $model.showSpaceSettingsData) {
                SpaceSettingsCoordinatorView(workspaceInfo: $0)
            }
            .anytypeSheet(item: $model.spaceJoinData) {
                SpaceJoinView(data: $0, onManageSpaces: {
                    model.onManageSpacesSelected()
                })
            }
    }
    
    private var content: some View {  
        ZStack {
            NotificationCoordinatorView(sceneId: model.sceneId)
            
            HomeBottomPanelContainer(
                path: $model.navigationPath,
                content: {
                    AnytypeNavigationView(path: $model.navigationPath, pathChanging: $model.pathChanging) { builder in
                        builder.appendBuilder(for: AccountInfo.self) { info in
                            HomeWidgetsView(info: info, output: model)
                        }
                        builder.appendBuilder(for: EditorScreenData.self) { data in
                            EditorCoordinatorView(data: data)
                        }
                        builder.appendBuilder(for: SpaceHubNavigationItem.self) { _ in
                            SpaceHubView(sceneId: model.sceneId)
                        }
                    }
                },
                bottomPanel: {
                    if let spaceInfo = model.spaceInfo {
                        HomeBottomNavigationPanelView(homePath: model.navigationPath, info: spaceInfo, output: model)
                    }
                }
            )
        }
        .animation(.easeInOut, value: model.spaceInfo)
        .environment(\.pageNavigation, model.pageNavigation)
    }
}

#Preview {
    SpaceHubCoordinatorView()
}
