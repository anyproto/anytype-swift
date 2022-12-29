import Foundation
import SwiftUI
import BlocksModels

final class ObjectTreeWidgetProvider: HomeWidgetProviderProtocol {
    
    private let widgetBlockId: String
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectTreeWidgetModuleAssembly: ObjectTreeWidgetModuleAssemblyProtocol
    
    init(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        objectTreeWidgetModuleAssembly: ObjectTreeWidgetModuleAssemblyProtocol
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectTreeWidgetModuleAssembly = objectTreeWidgetModuleAssembly
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    var view: AnyView {
        return objectTreeWidgetModuleAssembly.make(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    var componentId: String {
        return widgetBlockId
    }
}
