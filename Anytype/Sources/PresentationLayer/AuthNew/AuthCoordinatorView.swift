import SwiftUI

struct AuthCoordinatorView: View {
    
    @StateObject private var model: AuthCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init() {
        self._model = StateObject(wrappedValue: AuthCoordinatorViewModel())
    }
    
    var body: some View {
        NavigationStack {
            content
        }
    }
    
    private var content: some View {
        PrimaryAuthView(output: model)
            .sheet(isPresented: $model.showSettings) {
                ServerConfigurationCoordinatorView()
                    .mediumPresentationDetents()
            }
            .sheet(isPresented: $model.showDebugMenu) {
                DebugMenuView()
            }
            .navigationDestination(isPresented: $model.showLogin) {
                LoginCoordinatorView()
            }
    }
}
