import Foundation
import SwiftUI

struct SpaceSwitchCoordinatorView: View {
    
    @StateObject private var model = SpaceSwitchCoordinatorViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        SpaceSwitchView(output: model)
            .sheet(isPresented: $model.showSpaceCreate) {
                SpaceCreateView(output: model)
            }
            .sheet(isPresented: $model.showSettings) {
                SettingsCoordinatorView()
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
