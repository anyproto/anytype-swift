import Foundation
import SwiftUI
import AnytypeCore

struct ApplicationCoordinatorView: View {
    
    @StateObject private var model = ApplicationCoordinatorViewModel()
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    var body: some View {
        ZStack {
            applicationView
        }
        .onAppear {
            model.onAppear()
            model.setDismissAllPresented(dismissAllPresented: dismissAllPresented)
        }
        .task {
            await model.startAppStateHandler()
        }
        .task {
            await model.startAccountStateHandler()
        }
        .task {
            await model.startFileHandler()
        }
        .snackbar(toastBarData: $model.toastBarData)
    }
    
    @ViewBuilder
    private var applicationView: some View {
        switch model.applicationState {
        case .initial:
            InitialCoordinatorView()
        case .auth:
            model.authView()
                .preferredColorScheme(.dark)
        case .login:
            LaunchView {
                DebugMenuView()
            }
        case .home:
            if FeatureFlags.spaceHub {
                SpaceHubCoordinatorView()
            } else {
                HomeCoordinatorView(showHome: .constant(true))
            }
        case .delete:
            model.deleteAccount()
        }
    }
}
