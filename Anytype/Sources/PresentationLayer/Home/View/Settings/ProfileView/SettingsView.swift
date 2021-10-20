import SwiftUI
import Amplitude


struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject private var sectionModel: SettingSectionViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator()
            SettingsSectionView()
            Button(action: { sectionModel.loggingOut = true }) {
                AnytypeText("Log out".localized, style: .uxCalloutRegular, color: .textSecondary)
                    .padding()
            }
        }
        .background(Color.background)
        .cornerRadius(16)
        
        .environmentObject(viewModel)
        .environmentObject(sectionModel)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.pureAmber.ignoresSafeArea()
            SettingsView(
                viewModel: SettingsViewModel(
                    authService: ServiceLocator.shared.authService()
                )
            ).previewLayout(.fixed(width: 360, height: 276))
        }
    }
}

