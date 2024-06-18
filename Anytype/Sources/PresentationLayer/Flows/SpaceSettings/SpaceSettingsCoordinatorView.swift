import Foundation
import SwiftUI

struct SpaceSettingsCoordinatorView: View {
    
    @StateObject private var model = SpaceSettingsCoordinatorViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        SpaceSettingsView(output: model)
        .sheet(isPresented: $model.showRemoteStorage) {
            RemoteStorageView(output: model)
                .sheet(isPresented: $model.showFiles) {
                    WidgetObjectListFilesView()
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
        .sheet(isPresented: $model.showSpaceMembers) {
            SpaceMembersView()
        }
        .sheet(item: $model.showIconPickerSpaceViewId) {
            SpaceObjectIconPickerView(spaceViewId: $0.value)
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
