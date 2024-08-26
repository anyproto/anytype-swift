import Foundation
import SwiftUI
import Services

struct SpaceSettingsCoordinatorView: View {
    
    @StateObject private var model: SpaceSettingsCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(workspaceInfo: AccountInfo) {
        self._model = StateObject(wrappedValue: SpaceSettingsCoordinatorViewModel(workspaceInfo: workspaceInfo))
    }
    
    var body: some View {
        SpaceSettingsView(workspaceInfo: model.workspaceInfo, output: model)
        .sheet(isPresented: $model.showRemoteStorage) {
            RemoteStorageView(spaceId: model.accountSpaceId, output: model)
                .sheet(isPresented: $model.showFiles) {
                    WidgetObjectListFilesView(spaceId: model.accountSpaceId)
                }
        }
        .sheet(isPresented: $model.showPersonalization) {
            PersonalizationView(spaceId: model.accountSpaceId, output: model)
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
        }
        .sheet(isPresented: $model.showSpaceShare) {
            SpaceShareCoordinatorView()
        }
        .sheet(item: $model.showSpaceMembersDataSpaceId) {
            SpaceMembersView(spaceId: $0.value)
        }
        .sheet(item: $model.showIconPickerSpaceViewId) {
            SpaceObjectIconPickerView(spaceViewId: $0.value)
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
