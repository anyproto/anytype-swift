import Foundation
import SwiftUI
import Services

struct SpaceSettingsCoordinatorView: View {
    
    @StateObject private var model: SpaceSettingsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(workspaceInfo: AccountInfo) {
        self._model = StateObject(wrappedValue: SpaceSettingsCoordinatorViewModel(workspaceInfo: workspaceInfo))
    }
    
    var body: some View {
        SpaceSettingsView(workspaceInfo: model.workspaceInfo, output: model)
            .onAppear {
                model.pageNavigation = pageNavigation
            }
        
            .sheet(isPresented: $model.showRemoteStorage) {
                RemoteStorageView(spaceId: model.spaceId, output: model)
                    .sheet(isPresented: $model.showFiles) {
                        WidgetObjectListFilesManagerView(spaceId: model.spaceId)
                    }
            }
            .sheet(isPresented: $model.showWallpaperPicker) {
                WallpaperPickerView(spaceId: model.spaceId)
            }
            .sheet(isPresented: $model.showDefaultObjectTypeSearch) {
                ObjectTypeSearchView(
                    title: Loc.chooseDefaultObjectType,
                    spaceId: model.spaceId,
                    settings: .spaceDefaultObject
                ) { type in
                    model.onSelectDefaultObjectType(type: type)
                }
            }
            .sheet(item: $model.showSpaceShareData) {
                SpaceShareCoordinatorView(data: $0)
            }
            .sheet(item: $model.showSpaceMembersData) {
                SpaceMembersView(data: $0)
            }
    }
}
