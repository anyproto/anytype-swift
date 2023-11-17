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
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
