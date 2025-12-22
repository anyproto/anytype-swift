import SwiftUI

struct AuthCoordinatorView: View {
    
    private enum Constants {
        static let animationDuration = 0.6
    }
    
    @State private var model = AuthCoordinatorViewModel()
    @State private var showCircle: Bool = false
    
    var body: some View {
        NavigationStack {
            content
        }
        .authOverlayCircle(show: showCircle)
    }
    
    private var content: some View {
        PrimaryAuthView(output: model)
            .onAppear {
                withAnimation(.linear(duration: Constants.animationDuration)) {
                    showCircle = true
                }
            }
            .sheet(isPresented: $model.showSettings) {
                ServerConfigurationCoordinatorView()
            }
            .sheet(isPresented: $model.showDebugMenu) {
                DebugMenuView()
            }
            .navigationDestination(isPresented: $model.showLogin) {
                LoginCoordinatorView()
                    .onAppear {
                        withAnimation(.linear(duration: Constants.animationDuration)) {
                            showCircle = false
                        }
                    }
            }
            .navigationDestination(isPresented: $model.showJoinFlow) {
                if let state = model.joinState {
                    JoinCoordinatorView(state: state)
                        .onAppear {
                            withAnimation(.linear(duration: Constants.animationDuration)) {
                                showCircle = false
                            }
                        }
                }
            }
    }
}
