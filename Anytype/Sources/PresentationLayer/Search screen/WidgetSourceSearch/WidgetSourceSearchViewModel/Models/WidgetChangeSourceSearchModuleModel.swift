import Foundation

struct WidgetChangeSourceSearchModuleModel: Identifiable, Hashable {
    let widgetObjectId: String
    let spaceId: String
    let widgetId: String
    let context: AnalyticsWidgetContext
    
    var id: Int { hashValue }
}
