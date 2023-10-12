import Foundation
import Services

struct WidgetTypeModuleCreateModel: Identifiable, Hashable {
    let widgetObjectId: String
    let source: WidgetSource
    let position: WidgetPosition
    let context: AnalyticsWidgetContext
    @EquatableNoop var onFinish: () -> Void
    
    var id: Int { hashValue }
}
