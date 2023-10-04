import Foundation
import SwiftUI
import NavigationBackport

struct ApplicationCoordinatorView: View {
    
    @StateObject var model: ApplicationCoordinatorViewModel
    @State private var screenScrollViewPosition: CGPoint = .zero
    
    var body: some View {
        Group {
            applicationView
        }
        .onOpenURL { url in
            model.handleDeeplink(url: url)
        }
        .onAppear {
            model.onAppear()
        }
        .snackbar(toastBarData: $model.toastBarData)
    }
    
    // TODO: Navigation: Fix states
    
    @ViewBuilder
    var applicationView: some View {
        switch model.applicationState {
        case .initial:
            EmptyView()
        case .auth:
            model.authView()
                .preferredColorScheme(.dark)
        case .login:
            LaunchView()
        case .home:
            model.homeView()
        case .delete:
            EmptyView()
        }
    }
}
