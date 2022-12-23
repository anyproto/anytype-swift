import Foundation
import SwiftUI

@MainActor
final class ObjectLintWidgetProvider: HomeWidgetProviderProtocol {
    
    private let widgetBlockId: String
    
    init(widgetBlockId: String) {
        self.widgetBlockId = widgetBlockId
    }
    
    func view() -> AnyView {
        // TODO: Maybe add assembly for each widget
        let model = ObjectLintWidgetViewModel(name: widgetBlockId)
        return ObjectLintWidgetView(model: model).eraseToAnyView()
    }
    
    func componentId() -> String {
        return widgetBlockId
    }
}
