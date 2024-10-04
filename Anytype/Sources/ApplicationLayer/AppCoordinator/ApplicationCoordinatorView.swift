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
                .overrideDefaultInterfaceStyle(.dark)
        case .auth:
            model.authView()
                .overrideDefaultInterfaceStyle(.dark)
        case .login:
            LaunchView()
                .overrideDefaultInterfaceStyle(.dark)
        case .home:
            SpaceHubCoordinatorView()
                .overrideDefaultInterfaceStyle(nil)
        case .delete:
            model.deleteAccount()?
                .overrideDefaultInterfaceStyle(nil)
        }
    }
}
