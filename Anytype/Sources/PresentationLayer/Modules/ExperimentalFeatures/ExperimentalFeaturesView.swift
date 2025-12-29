import Foundation
import SwiftUI

struct ExperimentalFeaturesView: View {

    @StateObject private var model = ExperimentalFeaturesViewModel()
    @State private var showDebugMenu = false

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ModalNavigationHeader(title: Loc.experimentalFeatures)
                .onTapGesture(count: 5) {
                    showDebugMenu = true
                }
            ScrollView {
                VStack(spacing: 16) {
                    ExperimentalFeatureRow(
                        title: Loc.Experimental.NewObjectCreationMenu.title,
                        subtitle: Loc.Experimental.NewObjectCreationMenu.subtitle,
                        isOn: $model.newObjectCreationMenu
                    )
                }
                .padding(.horizontal, 16)
            }
        }
        .onChange(of: model.newObjectCreationMenu) {
            model.onUpdateNewObjectCreationMenu()
        }
        .sheet(isPresented: $showDebugMenu) {
            DebugMenuView()
        }
    }
}

#Preview {
    ExperimentalFeaturesView()
}
