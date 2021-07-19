import SwiftUI


struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @StateObject private var settingsSectionModel = SettingSectionViewModel()
    @State private var logginOut = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator()
            SettingsSectionView()
            Button(action: { logginOut = true }) {
                AnytypeText("Log out", style: .body)
                    .foregroundColor(.textSecondary)
                    .padding()
            }
        }
        .background(Color.background)
        .cornerRadius(16)
        
        .environmentObject(viewModel)
        .environmentObject(settingsSectionModel)
        
        .alert(isPresented: $logginOut) {
            alert
        }
    }
    
    private var alert: Alert {
        Alert(
            title: AnytypeText.buildText("Log out", style: .title),
            message: AnytypeText.buildText("Have you backed up your keychain phrase?", style: .subheading),
            primaryButton: Alert.Button.default(
                AnytypeText.buildText("Backup keychain phrase", style: .body)
            ) {
                settingsSectionModel.keychain = true
            },
            secondaryButton: Alert.Button.destructive(
                AnytypeText.buildText("Log out", style: .body)
            ) {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                viewModel.logout()
            }
        )
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

