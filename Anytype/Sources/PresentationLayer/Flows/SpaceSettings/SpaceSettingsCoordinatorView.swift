import Foundation
import SwiftUI

struct SpaceSettingsCoordinatorView: View {
    
    @StateObject var model: SpaceSettingsCoordinatorViewModel
    
    var body: some View {
        model.settingsModule()
            .sheet(isPresented: $model.showRemoteStorage) {
                model.remoteStorageModule()
            }
    }
}
