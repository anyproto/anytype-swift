import Foundation

struct WidgetTypeModuleChangeModel: Identifiable, Hashable {
    let widgetObjectId: String
    let widgetId: String
    let context: AnalyticsWidgetContext
    @EquatableNoop var onFinish: () -> Void
    
    var id: Int { hashValue }
}
