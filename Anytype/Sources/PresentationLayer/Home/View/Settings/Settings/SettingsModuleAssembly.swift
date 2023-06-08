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
            accountManager: serviceLocator.accountManager(),
            subscriptionService: serviceLocator.singleObjectSubscriptionService(),
            objectActionsService: serviceLocator.objectActionsService(),
            output: output
        )
        if FeatureFlags.homeWidgets {
            let view = SettingsView(model: model)
            return UIHostingController(rootView: view)
        } else {
            let view = OldSettingsView(model: model)
            return AnytypePopup(contentView: view, floatingPanelStyle: true)
        }
    }
}
