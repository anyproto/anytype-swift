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
            .task { await model.setup() }
            .task { await model.startHandleAppActions() }
            .task { await model.startHandleWorkspaceInfo() }
            
            .handleSpaceShareTip()
            .handleSharingTip()
            .updateShortcuts(spaceId: model.spaceInfo?.accountSpaceId)
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
                WidgetChangeSourceSearchView(data: $0)
            }
            .sheet(item: $model.showChangeTypeData) {
                WidgetTypeChangeView(data: $0)
            }
            .sheet(item: $model.showCreateWidgetData) {
                CreateWidgetCoordinatorView(data: $0)
            }
            .sheet(item: $model.showSpaceSwitchData) {
                SpaceSwitchCoordinatorView(data: $0)
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
                path: $model.editorPath,
                content: {
                    AnytypeNavigationView(path: $model.editorPath, pathChanging: $model.pathChanging) { builder in
                        builder.appendBuilder(for: AccountInfo.self) { info in
                            HomeWidgetsView(info: info, output: model)
                        }
                        builder.appendBuilder(for: EditorScreenData.self) { data in
                            EditorCoordinatorView(data: data)
                        }
                    }
                },
                bottomPanel: {
                    if let spaceInfo = model.spaceInfo {
                        HomeBottomNavigationPanelView(homePath: model.editorPath, info: spaceInfo, output: model)
                    }
                }
            )
        }
        .environment(\.pageNavigation, model.pageNavigation)
        
        
        // TODO: Support space hub
//        SpaceHubView(sceneId: model.sceneId)
//            .navigationDestination(isPresented: $model.showSpace) {
//                HomeCoordinatorView(sceneId: model.sceneId, spaceInfo: model.spaceInfo ?? .empty, showSpace: $model.showSpace)
//                    .navigationBarBackButtonHidden()
//                    .onChange(of: model.showSpace) {
//                        if !$0 { model.spaceInfo = nil }
//                    }
//            }
    }
}

#Preview {
    SpaceHubCoordinatorView()
}
