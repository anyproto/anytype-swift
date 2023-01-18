import Foundation
import SwiftUI
import BlocksModels

final class SetWidgetProvider: HomeWidgetProviderProtocol {
    
    private let widgetBlockId: String
    private let widgetObject: HomeWidgetsObjectProtocol
    private let setWidgetModuleAssembly: SetWidgetModuleAssemblyProtocol
    private weak var output: SetWidgetModuleOutput?
    
    init(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        setWidgetModuleAssembly: SetWidgetModuleAssemblyProtocol,
        output: SetWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.setWidgetModuleAssembly = setWidgetModuleAssembly
        self.output = output
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    lazy var view: AnyView = {
        return setWidgetModuleAssembly.make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            output: output
        )
    }()
    
    var componentId: String {
        return widgetBlockId
    }
}
