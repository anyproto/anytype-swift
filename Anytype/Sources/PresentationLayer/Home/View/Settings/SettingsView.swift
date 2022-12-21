import SwiftUI


struct SettingsView: View {
    @EnvironmentObject private var model: SettingsViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            DragIndicator()
            SettingsSectionView()
            Spacer.fixedHeight(16)
        }
        .background(Color.Background.secondary)
        .cornerRadius(16)
        
        .environmentObject(model)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.amber.ignoresSafeArea()
            SettingsView()
                .environmentObject(
                    SettingsViewModel(
                        authService: ServiceLocator.shared.authService(),
                        windowManager: DI.makeForPreview().coordinatorsDI.windowManager
                    )
                )
                .previewLayout(.fixed(width: 360, height: 276))
        }
    }
}

