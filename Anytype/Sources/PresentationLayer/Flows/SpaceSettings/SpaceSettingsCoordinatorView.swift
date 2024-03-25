import Foundation
import SwiftUI

struct SpaceSettingsCoordinatorView: View {
    
    @StateObject var model: SpaceSettingsCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        SpaceSettingsView(output: model)
        .sheet(isPresented: $model.showRemoteStorage) {
            model.remoteStorageModule()
        }
        .sheet(isPresented: $model.showPersonalization) {
            model.personalizationModule()
                .sheet(isPresented: $model.showWallpaperPicker) {
                    model.wallpaperModule()
                }
        }
        .sheet(isPresented: $model.showSpaceShare) {
            model.spaceShareModule()
        }
        .sheet(isPresented: $model.showSpaceMembers) {
            SpaceMembersView()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
