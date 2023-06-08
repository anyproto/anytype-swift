import Foundation
import SwiftUI

protocol KeychainPhraseModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(context: AnalyticsEventsKeychainContext) -> AnyView
}

final class KeychainPhraseModuleAssembly: KeychainPhraseModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - KeychainPhraseModuleAssemblyProtocol
    
    @MainActor
    func make(context: AnalyticsEventsKeychainContext) -> AnyView {
        let model = KeychainPhraseViewModel(shownInContext: context, seedService: serviceLocator.seedService())
        let view = KeychainPhraseView(model: model)
        return view.eraseToAnyView()
    }
}
