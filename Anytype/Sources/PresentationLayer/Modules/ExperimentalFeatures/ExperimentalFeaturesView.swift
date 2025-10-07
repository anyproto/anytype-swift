import Foundation
import SwiftUI

struct ExperimentalFeaturesView: View {
    
    @StateObject private var model = ExperimentalFeaturesViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ModalNavigationHeader(title: Loc.experimentalFeatures)
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
        .onChange(of: model.newObjectCreationMenu) { _ in
            model.onUpdateNewObjectCreationMenu()
        }
    }
}

#Preview {
    ExperimentalFeaturesView()
}
