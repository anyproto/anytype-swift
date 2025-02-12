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
        
            .task { await model.setup() }
            
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
            .sheet(item: $model.membershipTierId) { tierId in
                MembershipCoordinator(initialTierId: tierId.value)
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
            .anytypeSheet(item: $model.spaceJoinData) {
                SpaceJoinView(data: $0, onManageSpaces: {
                    model.onManageSpacesSelected()
                })
            }
            .anytypeSheet(item: $model.userWarningAlert, dismissOnBackgroundView: false) {
                UserWarningAlertCoordinatorView(alert: $0)
            }
            .anytypeSheet(isPresented: $model.showObjectIsNotAvailableAlert) {
                ObjectIsNotAvailableAlert()
            }
            .sheet(item: $model.showSpaceShareData) {
                SpaceShareCoordinatorView(data: $0)
            }
            .sheet(item: $model.showSpaceMembersData) {
                SpaceMembersView(data: $0)
            }
            .anytypeSheet(item: $model.profileData) {
                ProfileView(info: $0)
            }
            .safariBookmarkObject($model.bookmarkScreenData) {
                model.onOpenBookmarkAsObject($0)
            }
    }
    
    private var content: some View {  
        ZStack {
            NotificationCoordinatorView(sceneId: model.sceneId)
            
            HomeBottomPanelContainer(
                path: $model.navigationPath,
                content: {
                    AnytypeNavigationView(path: $model.navigationPath, pathChanging: $model.pathChanging) { builder in
                        builder.appendBuilder(for: HomeWidgetData.self) { data in
                            HomeWidgetsCoordinatorView(data: data)
                        }
                        builder.appendBuilder(for: EditorScreenData.self) { data in
                            EditorCoordinatorView(data: data)
                        }
                        builder.appendBuilder(for: SpaceHubNavigationItem.self) { _ in
                            SpaceHubView(sceneId: model.sceneId)
                        }
                        builder.appendBuilder(for: ChatCoordinatorData.self) {
                            ChatCoordinatorView(data: $0)
                        }
                        builder.appendBuilder(for: AccountInfo.self) {
                            NewSpaceSettingsCoordinatorView(workspaceInfo: $0)
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
        .pageNavigation(model.pageNavigation)
        .chatActionProvider($model.chatProvider)
    }
}

#Preview {
    SpaceHubCoordinatorView()
}
