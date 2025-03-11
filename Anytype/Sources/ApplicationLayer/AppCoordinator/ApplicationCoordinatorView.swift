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
        .task(item: model.selectAccountTaskId) { accountId in
            await model.selectAccount(id: accountId)
        }
        .onChange(of: dismissAllPresented) {
            model.setDismissAllPresented(dismissAllPresented: $0)
        }
        .snackbar(toastBarData: $model.toastBarData)
        
        // migration
        .fullScreenCover(item: $model.migrationData) {
            MigrationView(data: $0)
        }
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
