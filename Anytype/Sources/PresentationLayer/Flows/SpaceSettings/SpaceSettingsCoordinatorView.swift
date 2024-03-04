import Foundation
import SwiftUI

struct SpaceSettingsCoordinatorView: View {
    
    @StateObject var model: SpaceSettingsCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        model.settingsModule()
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
            model.spaceMembersModule()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
