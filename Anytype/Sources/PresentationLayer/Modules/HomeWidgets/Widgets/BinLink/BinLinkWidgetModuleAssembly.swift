import Foundation
import SwiftUI

protocol BinLinkWidgetModuleAssemblyProtocol {
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView
}

final class BinLinkWidgetModuleAssembly: BinLinkWidgetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - BinLinkWidgetModuleAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        
        let contentModel = BinLinkWidgetViewModel(
            output: output
        )
        let contentView = EmptyView()
        
        let containerModel = WidgetContainerViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            blockWidgetService: serviceLocator.blockWidgetService(),
            stateManager: stateManager,
            blockWidgetExpandedService: serviceLocator.blockWidgetExpandedService()
        )
        let containterView = WidgetContainerView(
            model: containerModel,
            contentModel: contentModel,
            content: contentView
        )
        return containterView.eraseToAnyView()
    }
}
