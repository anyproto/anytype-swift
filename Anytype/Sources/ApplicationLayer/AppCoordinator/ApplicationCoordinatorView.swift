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
            await model.startEncryptionKeyEventHandler()
        }
        .task {
            await model.startFileHandler()
        }
        .task(item: model.selectAccountTaskId) { accountId in
            await model.selectAccount(id: accountId)
        }
        .onChange(of: dismissAllPresented) {
            model.setDismissAllPresented(dismissAllPresented: $1)
        }
        .snackbar(toastBarData: $model.toastBarData)
        // migration
        .fullScreenCover(item: $model.migrationData) {
            MigrationCoordinatorView(data: $0)
        }
    }
    
    @ViewBuilder
    private var applicationView: some View {
        switch model.applicationState {
        case .initial:
            InitialCoordinatorView()
                .if(!FeatureFlags.brandNewAuthFlow) {
                    $0.overrideDefaultInterfaceStyle(.dark)
                }
        case .auth:
            if FeatureFlags.brandNewAuthFlow {
                AuthCoordinatorView()
            } else {
                model.authView()
                    .overrideDefaultInterfaceStyle(.dark)
            }
        case .login:
            LaunchView()
                .if(!FeatureFlags.brandNewAuthFlow) {
                    $0.overrideDefaultInterfaceStyle(.dark)
                }
        case .home:
            SpaceHubCoordinatorView()
                .if(!FeatureFlags.brandNewAuthFlow) {
                    $0.overrideDefaultInterfaceStyle(nil)
                }
        case .delete:
            model.deleteAccount()?
                .if(!FeatureFlags.brandNewAuthFlow) {
                    $0.overrideDefaultInterfaceStyle(nil)
                }
        }
    }
}
