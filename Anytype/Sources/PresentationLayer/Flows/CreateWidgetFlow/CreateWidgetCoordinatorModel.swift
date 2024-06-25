import Foundation
import Services

struct CreateWidgetCoordinatorModel: Identifiable, Hashable {
    let spaceId: String
    let widgetObjectId: String
    let position: WidgetPosition
    let context: AnalyticsWidgetContext
    
    var id: Int { hashValue }
}
