import Foundation
import SwiftUI

struct ServerConfigurationCoordinatorView: View {
    
    @StateObject private var model = ServerConfigurationCoordinatorViewModel()
    
    var body: some View {
        ServerConfigurationView(output: model)
            .sheet(isPresented: $model.showDocumentPicker) {
                ServerDocumentPickerView()
            }
    }
}
