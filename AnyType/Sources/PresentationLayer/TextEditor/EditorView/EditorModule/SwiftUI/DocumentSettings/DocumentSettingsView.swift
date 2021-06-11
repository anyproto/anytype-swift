import SwiftUI

struct DocumentSettingsView: View {
    
    @StateObject private var settingsListViewModel = DocumentSettingsListViewModel()
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 0
        ) {
            DragIndicator()
            DocumentSettingsListView()
        }
        .background(Color.background)
        .cornerRadius(16)
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


