import Foundation
import SwiftUI
import AnytypeCore

struct ApplicationCoordinatorView: View {
    
    @StateObject private var model = ApplicationCoordinatorViewModel()
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    @Environment(\.appInterfaceStyle) private var appInterfaceStyle
    
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
                .onAppear { appInterfaceStyle.overrideDefaultStyle(.dark) }
        case .auth:
            model.authView()
                .onAppear { appInterfaceStyle.overrideDefaultStyle(.dark) }
        case .login:
            LaunchView {
                DebugMenuView()
            }
            .onAppear { appInterfaceStyle.overrideDefaultStyle(.dark) }
        case .home:
            SpaceHubCoordinatorView()
                .onAppear { appInterfaceStyle.overrideDefaultStyle(nil) }
        case .delete:
            model.deleteAccount()
                .onAppear { appInterfaceStyle.overrideDefaultStyle(.dark) }
        }
    }
}
