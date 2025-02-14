import Foundation
import SwiftUI
import Services

struct NewSpaceSettingsCoordinatorView: View {
    
    @StateObject private var model: NewSpaceSettingsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(workspaceInfo: AccountInfo) {
        self._model = StateObject(wrappedValue: NewSpaceSettingsCoordinatorViewModel(workspaceInfo: workspaceInfo))
    }
    
    var body: some View {
        NewSpaceSettingsView(workspaceInfo: model.workspaceInfo, output: model)
            .onAppear {
                model.pageNavigation = pageNavigation
            }
        
        
            .sheet(isPresented: $model.showRemoteStorage) {
                RemoteStorageView(spaceId: model.accountSpaceId, output: model)
                    .sheet(isPresented: $model.showFiles) {
                        WidgetObjectListFilesManagerView(spaceId: model.accountSpaceId)
                    }
            }
            .sheet(isPresented: $model.showWallpaperPicker) {
                WallpaperPickerView(spaceId: model.accountSpaceId)
            }
            .sheet(isPresented: $model.showObjectTypeSearch) {
                ObjectTypeSearchView(
                    title: Loc.chooseDefaultObjectType,
                    spaceId: model.accountSpaceId,
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
