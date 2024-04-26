import Foundation
import SwiftUI

struct SpaceSwitchCoordinatorView: View {
    
    @StateObject var model: SpaceSwitchCoordinatorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        SpaceSwitchView(output: model)
            .sheet(isPresented: $model.showSpaceCreate) {
                SpaceCreateView(output: model)
            }
            .sheet(isPresented: $model.showSettings) {
                model.settingsView()
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
