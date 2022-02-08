import SwiftUI
import Amplitude


struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator()
            SettingsSectionView()
            Button(action: { viewModel.loggingOut = true }) {
                AnytypeText("Log out".localized, style: .uxCalloutRegular, color: .textSecondary)
                    .padding()
            }
        }
        .background(Color.backgroundSecondary)
        .cornerRadius(16)
        
        .sheet(isPresented: $viewModel.defaultType) {
            DefaultTypePicker()
                .environmentObject(viewModel)
        }
        
        .environmentObject(viewModel)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.amber.ignoresSafeArea()
            SettingsView()
                .environmentObject(SettingsViewModel(authService: ServiceLocator.shared.authService()))
                .previewLayout(.fixed(width: 360, height: 276))
        }
    }
}

