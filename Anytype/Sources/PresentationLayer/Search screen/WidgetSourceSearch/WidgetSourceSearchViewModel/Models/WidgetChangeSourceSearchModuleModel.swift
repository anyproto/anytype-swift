import Foundation

struct WidgetChangeSourceSearchModuleModel: Identifiable, Hashable {
    let widgetObjectId: String
    let spaceId: String
    let widgetId: String
    let context: AnalyticsWidgetContext
    @EquatableNoop var onFinish: () -> Void
    
    var id: Int { hashValue }
}
