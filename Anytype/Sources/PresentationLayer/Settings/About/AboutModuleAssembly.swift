import Foundation
import SwiftUI
import AnytypeCore

protocol AboutModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(output: AboutModuleOutput?) -> UIViewController
}

final class AboutModuleAssembly: AboutModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - AboutModuleAssemblyProtocol
    
    @MainActor
    func make(output: AboutModuleOutput?) -> UIViewController {
        
        if FeatureFlags.redesignAbout {
            let model = AboutViewModel(
                middlewareConfigurationProvider: serviceLocator.middlewareConfigurationProvider(),
                accountManager: serviceLocator.accountManager(),
                output: output
            )
            let view = AboutView(model: model)
            return UIHostingController(rootView: view)
        } else {
            let model = AboutLegacyViewModel(
                middlewareConfigurationProvider: serviceLocator.middlewareConfigurationProvider(),
                accountManager: serviceLocator.accountManager(),
                output: output
            )
            let view = AboutLegacyView(model: model)
            return AnytypePopup(contentView: view)
        }
    }
}
