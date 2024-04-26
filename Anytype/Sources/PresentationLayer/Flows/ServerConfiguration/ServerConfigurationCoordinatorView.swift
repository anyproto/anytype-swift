import Foundation
import SwiftUI

struct ServerConfigurationCoordinatorView: View {
    
    @StateObject var model: ServerConfigurationCoordinatorViewModel
    
    var body: some View {
        model.makeSettingsView()
            .sheet(isPresented: $model.showDocumentPicker) {
                model.makeDocumentPickerView()
            }
    }
}
