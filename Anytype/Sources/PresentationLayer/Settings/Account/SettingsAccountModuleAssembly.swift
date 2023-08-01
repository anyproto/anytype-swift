import Foundation
import UIKit
import AnytypeCore
import SwiftUI

protocol SettingsAccountModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(output: SettingsAccountModuleOutput?) -> UIViewController
}

final class SettingsAccountModuleAssembly: SettingsAccountModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - SettingsModuleAssemblyProtocol
    
    @MainActor
    func make(output: SettingsAccountModuleOutput?) -> UIViewController {
        let model = SettingsAccountViewModel(
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            subscriptionService: serviceLocator.singleObjectSubscriptionService(),
            objectActionsService: serviceLocator.objectActionsService(),
            output: output
        )

        let view = SettingsAccountView(model: model)
        return UIHostingController(rootView: view)
    }
}
