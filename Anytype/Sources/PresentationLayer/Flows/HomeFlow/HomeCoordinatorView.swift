import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeCoordinatorView: View {
    
    @StateObject private var model = HomeCoordinatorViewModel()
    @Environment(\.keyboardDismiss) var keyboardDismiss
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    var body: some View {
        ZStack {
            
            NotificationCoordinatorView()
            
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
        .onAppear {
            model.onAppear()
            model.setDismissAllPresented(dismissAllPresented: dismissAllPresented)
        }
        .task {
            await model.startDeepLinkTask()
        }
        .environment(\.pageNavigation, model.pageNavigation)
        .onChange(of: model.keyboardToggle) { _ in
            keyboardDismiss()
        }
        .handleSpaceShareTip()
        .snackbar(toastBarData: $model.toastBarData)
        .sheet(item: $model.showChangeSourceData) {
            WidgetChangeSourceSearchView(data: $0)
        }
        .sheet(item: $model.showChangeTypeData) {
            WidgetTypeChangeView(data: $0)
        }
        .sheet(item: $model.showSearchData) {
            ObjectSearchView(data: $0)
        }
        .sheet(item: $model.showGlobalSearchData) {
            GlobalSearchView(data: $0)
        }
        .sheet(item: $model.showCreateWidgetData) {
            CreateWidgetCoordinatorView(data: $0)
        }
        .sheet(isPresented: $model.showSpaceSwitch) {
            SpaceSwitchCoordinatorView()
        }
        .sheet(isPresented: $model.showSpaceSettings) {
            SpaceSettingsCoordinatorView()
        }
        .sheet(isPresented: $model.showSharing) {
            ShareCoordinatorView()
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
    }
}

#Preview {
    HomeCoordinatorView()
}
