import Foundation
import SwiftUI

protocol FileStorageModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(output: FileStorageModuleOutput?) -> AnyView
}

final class FileStorageModuleAssembly: FileStorageModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - FileStorageModuleAssemblyProtocol
    
    @MainActor
    func make(output: FileStorageModuleOutput?) -> AnyView {
        let model = FileStorageViewModel(
            accountManager: serviceLocator.accountManager(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            subscriptionService: serviceLocator.singleObjectSubscriptionService(),
            fileLimitsStorage: serviceLocator.fileLimitsStorage(),
            output: output
        )
        let view = FileStorageView(model: model)
        return view.eraseToAnyView()
    }
}
