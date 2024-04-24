import Foundation
import SwiftUI

struct SettingsCoordinatorView: View {
    
    @StateObject var model: SettingsCoordinatorViewModel
    
    var body: some View {
        SettingsView(output: model)
            .sheet(isPresented: $model.showFileStorage) {
                FileStorageView()
            }
    }
}
