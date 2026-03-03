import Foundation
import SwiftUI

struct ExperimentalFeaturesView: View {

    @State private var model = ExperimentalFeaturesViewModel()
    @State private var showDebugMenu = false

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            NavigationHeader(title: Loc.experimentalFeatures, navigationButtonType: .none)
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
                    ExperimentalFeatureRow(
                        title: Loc.Experimental.CompactVault.title,
                        subtitle: Loc.Experimental.CompactVault.subtitle,
                        isOn: $model.hideReadPreviews
                    )
                }
                .padding(.horizontal, 16)
            }
        }
        .onChange(of: model.newObjectCreationMenu) {
            model.onUpdateNewObjectCreationMenu()
        }
        .onChange(of: model.hideReadPreviews) {
            model.onUpdateHideReadPreviews()
        }
        .sheet(isPresented: $showDebugMenu) {
            DebugMenuView()
        }
    }
}

#Preview {
    ExperimentalFeaturesView()
}
