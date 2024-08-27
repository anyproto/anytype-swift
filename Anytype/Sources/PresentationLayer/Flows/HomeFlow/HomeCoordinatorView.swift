import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeCoordinatorView: View {
    
    @StateObject private var model: HomeCoordinatorViewModel
    
    init(sceneId: String, spaceInfo: AccountInfo, showSpace: Binding<Bool>) {
        _model = StateObject(
            wrappedValue: HomeCoordinatorViewModel(sceneId: sceneId, spaceInfo: spaceInfo, showSpace: showSpace)
        )
    }
    
    var body: some View {
        ZStack {
            NotificationCoordinatorView(sceneId: model.spaceInfo.accountSpaceId)
            
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
    HomeCoordinatorView(sceneId: "1337", spaceInfo: .empty, showSpace: .constant(true))
}
