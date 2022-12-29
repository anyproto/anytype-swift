import Foundation
import SwiftUI

protocol ObjectTreeWidgetModuleAssemblyProtocol {
    @MainActor
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol) -> AnyView
}

final class ObjectTreeWidgetModuleAssembly: ObjectTreeWidgetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - ObjectTreeWidgetModuleAssemblyProtocol
    
    @MainActor
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol) -> AnyView {
        
        let subscriptionManager = ObjectTreeSubscriptionManager(
            subscriptionDataBuilder: ObjectTreeSubscriptionDataBuilder(),
            subscriptionService: serviceLocator.subscriptionService(),
            objectTypeProvider: serviceLocator.objectTypeProvider()
        )
        
        let model = ObjectTreeWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            objectDetailsStorage: serviceLocator.objectDetailsStorage(),
            subscriptionManager: subscriptionManager
        )
        return ObjectTreeWidgetView(model: model).eraseToAnyView()
    }
}
