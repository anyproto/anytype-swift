import Foundation

struct WidgetSourceSearchModuleModel: Identifiable, Hashable {
    let spaceId: String
    let context: AnalyticsWidgetContext
    @EquatableNoop var onSelect: (_ source: WidgetSource) -> Void
    
    var id: Int { hashValue }
}
