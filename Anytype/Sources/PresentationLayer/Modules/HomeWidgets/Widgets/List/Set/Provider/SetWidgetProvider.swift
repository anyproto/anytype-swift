import Foundation
import SwiftUI
import BlocksModels

final class SetWidgetProvider: HomeWidgetProviderProtocol {
    
    private let widgetBlockId: String
    private let widgetObject: HomeWidgetsObjectProtocol
    private let setWidgetModuleAssembly: SetWidgetModuleAssemblyProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    init(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        setWidgetModuleAssembly: SetWidgetModuleAssemblyProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.setWidgetModuleAssembly = setWidgetModuleAssembly
        self.stateManager = stateManager
        self.output = output
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    lazy var view: AnyView = {
        return setWidgetModuleAssembly.make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            stateManager: stateManager,
            output: output
        )
    }()
    
    var componentId: String {
        return widgetBlockId
    }
}
