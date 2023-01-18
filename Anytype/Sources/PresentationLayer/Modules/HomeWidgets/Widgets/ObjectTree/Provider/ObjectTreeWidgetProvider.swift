import Foundation
import SwiftUI
import BlocksModels

final class ObjectTreeWidgetProvider: HomeWidgetProviderProtocol {
    
    private let widgetBlockId: String
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectTreeWidgetModuleAssembly: ObjectTreeWidgetModuleAssemblyProtocol
    private weak var output: ObjectTreeWidgetModuleOutput?
    
    init(
        widgetBlockId: String,
        widgetObject: HomeWidgetsObjectProtocol,
        objectTreeWidgetModuleAssembly: ObjectTreeWidgetModuleAssemblyProtocol,
        output: ObjectTreeWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectTreeWidgetModuleAssembly = objectTreeWidgetModuleAssembly
        self.output = output
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    lazy var view: AnyView = {
        return objectTreeWidgetModuleAssembly.make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            output: output
        )
    }()
    
    var componentId: String {
        return widgetBlockId
    }
}
