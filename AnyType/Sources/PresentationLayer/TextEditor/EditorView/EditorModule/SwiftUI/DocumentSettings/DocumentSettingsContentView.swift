import SwiftUI

struct DocumentSettingsContentView: View {
    
    @StateObject private var settingsListViewModel = DocumentSettingsListViewModel()
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 0
        ) {
            DragIndicator()
            DocumentSettingsList()
        }
        .background(Color.background)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.35), radius: 40, x: 0, y: 4)
        .environmentObject(settingsListViewModel)
    }
}

struct DocumentSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.pureAmber.ignoresSafeArea()
            SettingsView(
                model: SettingsViewModel(
                    authService: ServiceLocator.shared.authService()
                )
            )
            .previewLayout(.fixed(width: 360, height: 276))
        }
    }
}


