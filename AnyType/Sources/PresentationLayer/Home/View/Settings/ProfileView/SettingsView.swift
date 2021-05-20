import SwiftUI

struct SettingsView: View {
    @StateObject var model: SettingsViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator()
            SettingsSectionView()
            Button(action: model.logout) {
                AnytypeText("Log out", style: .body)
                    .foregroundColor(.textSecondary)
                    .padding()
            }
        }
        .background(Color.background)
        .cornerRadius(16)
        
        .environmentObject(model)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.pureAmber.ignoresSafeArea()
            SettingsView(
                model: SettingsViewModel(
                    authService: ServiceLocator.shared.authService()
                )
            ).previewLayout(.fixed(width: 360, height: 276))
        }
    }
}

