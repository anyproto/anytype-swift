import Foundation
import UIKit
import AnytypeCore
import SwiftUI

protocol SettingsModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(output: SettingsModuleOutput?) -> UIViewController
}

final class SettingsModuleAssembly: SettingsModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SettingsModuleAssemblyProtocol
    
    @MainActor
    func make(output: SettingsModuleOutput?) -> UIViewController {
        let model = SettingsViewModel(
            activeSpaceStorage: serviceLocator.activeSpaceStorage(),
            subscriptionService: serviceLocator.singleObjectSubscriptionService(),
            objectActionsService: serviceLocator.objectActionsService(),
            output: output
        )

        let view = SettingsView(model: model)
        return UIHostingController(rootView: view)
    }
}
