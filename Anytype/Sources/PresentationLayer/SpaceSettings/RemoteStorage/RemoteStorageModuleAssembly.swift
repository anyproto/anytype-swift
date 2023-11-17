import Foundation
import SwiftUI

protocol RemoteStorageModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(output: RemoteStorageModuleOutput?) -> AnyView
}

final class RemoteStorageModuleAssembly: RemoteStorageModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - RemoteStorageModuleAssemblyProtocol
    
    @MainActor
    func make(output: RemoteStorageModuleOutput?) -> AnyView {
        let view = RemoteStorageView(
            model: RemoteStorageViewModel(
                accountManager: self.serviceLocator.accountManager(),
                activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                subscriptionService: self.serviceLocator.singleObjectSubscriptionService(),
                fileLimitsStorage: self.serviceLocator.fileLimitsStorage(),
                documentProvider: self.serviceLocator.documentsProvider,
                workspacesStorage: self.serviceLocator.workspaceStorage(),
                output: output
            )
        )
        return view.eraseToAnyView()
    }
}
