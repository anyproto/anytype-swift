import Foundation
import SwiftUI

struct ServerConfigurationCoordinatorView: View {
    
    @StateObject var model: ServerConfigurationCoordinatorViewModel
    
    var body: some View {
        ServerConfigurationView(output: model)
            .sheet(isPresented: $model.showDocumentPicker) {
                model.makeDocumentPickerView()
            }
    }
}
