import Foundation
import SwiftUI
import Services
import AnytypeCore

struct NewHomeCoordinatorView: View {
    
    @StateObject private var model: NewHomeCoordinatorViewModel
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    init(homeSceneId: String, spaceInfo: AccountInfo, showHome: Binding<Bool>) {
        _model = StateObject(
            wrappedValue: NewHomeCoordinatorViewModel(homeSceneId: homeSceneId, spaceInfo: spaceInfo, showHome: showHome)
        )
    }
    
    var body: some View {
        ZStack {
            NotificationCoordinatorView(homeSceneId: model.spaceInfo.accountSpaceId)
            
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
                    HomeBottomNavigationPanelView(homePath: model.editorPath, info: model.spaceInfo, output: model)
                }
            )
        }
        .onAppear {
            model.setDismissAllPresented(dismissAllPresented: dismissAllPresented)
        }
        .environment(\.pageNavigation, model.pageNavigation)
        .handleSpaceShareTip()
        .handleSharingTip()
        .updateShortcuts(spaceId: model.spaceInfo.accountSpaceId)
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
        .sheet(isPresented: $model.showTypeSearchForObjectCreation) {
            model.typeSearchForObjectCreationModule()
        }
        .sheet(item: $model.showMembershipNameSheet) {
            MembershipNameFinalizationView(tier: $0)
        }
    }
}

#Preview {
    NewHomeCoordinatorView(homeSceneId: "1337", spaceInfo: .empty, showHome: .constant(true))
}
