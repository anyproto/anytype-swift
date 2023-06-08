import SwiftUI

struct OldSettingsView: View {
    
    @ObservedObject var model: SettingsViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SettingsSectionView(viewModel: model)
            Spacer.fixedHeight(16)
        }
        .background(Color.Background.secondary)
        .cornerRadius(16)
        .onAppear {
            model.onAppear()
        }
    }
}
