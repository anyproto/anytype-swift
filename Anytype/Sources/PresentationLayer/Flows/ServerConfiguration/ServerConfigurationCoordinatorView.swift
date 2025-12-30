import Foundation
import SwiftUI

struct ServerConfigurationCoordinatorView: View {

    @State private var model = ServerConfigurationCoordinatorViewModel()
    
    var body: some View {
        ServerConfigurationView(output: model)
            .sheet(isPresented: $model.showDocumentPicker) {
                ServerDocumentPickerView()
            }
    }
}
