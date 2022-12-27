import Foundation
import SwiftUI
import BlocksModels

final class ObjectTreeWidgetProvider: HomeWidgetProviderProtocol {
    
    private let widgetBlockId: String
    private let widgetObject: HomeWidgetsObjectProtocol
    private let objectDetailsStorage: ObjectDetailsStorage
    
    init(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol, objectDetailsStorage: ObjectDetailsStorage) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.objectDetailsStorage = objectDetailsStorage
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    @MainActor
    var view: AnyView {
        // TODO: Maybe add assembly for each widget
        let model = ObjectTreeWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            objectDetailsStorage: objectDetailsStorage
        )
        return ObjectTreeWidgetView(model: model).eraseToAnyView()
    }
    
    var componentId: String {
        return widgetBlockId
    }
}
