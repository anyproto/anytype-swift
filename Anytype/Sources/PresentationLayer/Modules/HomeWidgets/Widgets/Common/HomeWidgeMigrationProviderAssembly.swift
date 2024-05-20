import Foundation
import SwiftUI

// Temp class for migration
final class HomeWidgeMigrationProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
    // MARK: - HomeWidgetProviderAssemblyProtocol
    
    private let view: AnyView
    private let componentId: String
    
    init(view: AnyView, componentId: String) {
        self.view = view
        self.componentId = componentId
    }
    
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol
    ) -> HomeSubmoduleProviderProtocol {
        HomeSubmoduleMigrationProvider(view: view, componentId: componentId)
    }
}

final class HomeSubmoduleMigrationProvider: HomeSubmoduleProviderProtocol {
    
    let view: AnyView
    let componentId: String
    
    init(view: AnyView, componentId: String) {
        self.view = view
        self.componentId = componentId
    }
}
