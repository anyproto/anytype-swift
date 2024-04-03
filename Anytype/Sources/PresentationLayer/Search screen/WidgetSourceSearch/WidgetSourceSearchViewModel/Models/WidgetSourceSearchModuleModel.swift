import Foundation

struct WidgetSourceSearchModuleModel: Identifiable, Hashable {
    let spaceId: String
    let context: AnalyticsWidgetContext
    
    var id: Int { hashValue }
}
