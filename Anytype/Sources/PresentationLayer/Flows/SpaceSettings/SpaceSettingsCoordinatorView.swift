import Foundation
import SwiftUI

struct SpaceSettingsCoordinatorView: View {
    
    @StateObject var model: SpaceSettingsCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        SpaceSettingsView(output: model)
        .sheet(isPresented: $model.showRemoteStorage) {
            RemoteStorageView(output: model)
        }
        .sheet(isPresented: $model.showPersonalization) {
            model.personalizationModule()
                .sheet(isPresented: $model.showWallpaperPicker) {
                    WallpaperPickerView(spaceId: model.accountSpaceId)
                }
        }
        .sheet(isPresented: $model.showSpaceShare) {
            SpaceShareCoordinatorView()
        }
        .sheet(isPresented: $model.showSpaceMembers) {
            SpaceMembersView()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
