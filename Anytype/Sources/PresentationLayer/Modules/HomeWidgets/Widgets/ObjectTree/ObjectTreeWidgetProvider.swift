import Foundation
import SwiftUI

@MainActor
final class ObjectTreeWidgetProvider: HomeWidgetProviderProtocol {
    
    private let widgetBlockId: String
    
    init(widgetBlockId: String) {
        self.widgetBlockId = widgetBlockId
    }
    
    // MARK: - HomeWidgetProviderProtocol
    
    var view: AnyView {
        // TODO: Maybe add assembly for each widget
        let model = ObjectTreeWidgetViewModel(name: widgetBlockId)
        return ObjectTreeWidgetView(model: model).eraseToAnyView()
    }
    
    var componentId: String {
        return widgetBlockId
    }
}
