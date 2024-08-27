import Foundation
import SwiftUI

struct SpaceSwitchCoordinatorView: View {
    
    @StateObject private var model: SpaceSwitchCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: SpaceSwitchModuleData) {
        self._model = StateObject(wrappedValue: SpaceSwitchCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        SpaceSwitchView(data: model.data, output: model)
            .sheet(isPresented: $model.showSpaceCreate) {
                SpaceCreateView(sceneId: model.data.sceneId, output: model)
            }
            .sheet(isPresented: $model.showSettings) {
                SettingsCoordinatorView()
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
