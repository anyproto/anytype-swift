import Foundation
import SwiftUI
import BlocksModels

final class HomeWidgetCommonProvider: HomeSubmoduleProviderProtocol {
    
    private let widgetBlockId: String
    private let widgetObject: HomeWidgetsObjectProtocol
    private let widgetAssembly: HomeWidgetCommonAssemblyProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    init(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        widgetAssembly: HomeWidgetCommonAssemblyProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.widgetAssembly = widgetAssembly
        self.stateManager = stateManager
        self.output = output
    }
    
    // MARK: - HomeSubmoduleProviderProtocol
    
    @MainActor
    lazy var view: AnyView = {
        return widgetAssembly.make(
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
