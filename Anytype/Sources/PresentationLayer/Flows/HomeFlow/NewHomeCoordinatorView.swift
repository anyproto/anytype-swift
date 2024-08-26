import Foundation
import SwiftUI
import Services
import AnytypeCore

struct NewHomeCoordinatorView: View {
    
    @StateObject private var model: NewHomeCoordinatorViewModel
    @Environment(\.keyboardDismiss) var keyboardDismiss
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    init(showHome: Binding<Bool>) {
        _model = StateObject(wrappedValue: NewHomeCoordinatorViewModel(showHome: showHome))
    }
    
    var body: some View {
        ZStack {
            
            if let info = model.info {
                NotificationCoordinatorView(homeSceneId: info.accountSpaceId)
            }
            
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
                    if let info = model.info {
                        HomeBottomNavigationPanelView(homePath: model.editorPath, info: info, output: model)
                    }
                }
            )
        }
        .task {
            await model.startHandleWorkspaceInfo()
        }
        .onAppear {
            model.setDismissAllPresented(dismissAllPresented: dismissAllPresented)
        }
        .ifLet(model.info) { view, _ in
            view.task {
                await model.startDeepLinkTask()
            }
        }
        .environment(\.pageNavigation, model.pageNavigation)
        .onChange(of: model.keyboardToggle) { _ in
            keyboardDismiss()
        }
        .handleSpaceShareTip()
        .handleSharingTip()
        .updateShortcuts(spaceId: model.info?.accountSpaceId)
        .snackbar(toastBarData: $model.toastBarData)
        .sheet(item: $model.showChangeSourceData) {
            WidgetChangeSourceSearchView(data: $0)
        }
        .sheet(item: $model.showChangeTypeData) {
            WidgetTypeChangeView(data: $0)
        }
        .sheet(item: $model.showGlobalSearchData) {
            GlobalSearchView(data: $0)
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
        .sheet(item: $model.showSharingDataSpaceId) {
            ShareCoordinatorView(spaceId: $0.value)
        }
        .sheet(isPresented: $model.showTypeSearchForObjectCreation) {
            model.typeSearchForObjectCreationModule()
        }
        .sheet(isPresented: $model.showSpaceManager) {
            SpacesManagerView()
        }
        .sheet(item: $model.showMembershipNameSheet) {
            MembershipNameFinalizationView(tier: $0)
        }
        .anytypeSheet(item: $model.spaceJoinData) {
            SpaceJoinView(data: $0, onManageSpaces: {
                model.onManageSpacesSelected()
            })
        }
        .sheet(item: $model.showGalleryImport) { data in
            GalleryInstallationCoordinatorView(data: data)
        }
        .sheet(isPresented: $model.showSpaceShareTip) {
            SpaceShareTipView()
        }
        .sheet(item: $model.membershipTierId) { tierId in
            MembershipCoordinator(initialTierId: tierId.value)
        }
    }
}

#Preview {
    NewHomeCoordinatorView(showHome: .constant(true))
}
