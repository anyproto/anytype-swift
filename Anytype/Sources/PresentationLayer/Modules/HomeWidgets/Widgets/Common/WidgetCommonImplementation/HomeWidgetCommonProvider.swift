import Foundation
import SwiftUI
import Services

final class HomeWidgetCommonProvider: HomeSubmoduleProviderProtocol {
    
    private let widgetBlockId: String
    private let widgetObject: BaseDocumentProtocol
    private let widgetAssembly: HomeWidgetCommonAssemblyProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
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
