import Foundation
import Services

struct CreateWidgetCoordinatorModel: Identifiable, Hashable {
    let widgetObjectId: String
    let spaceId: String
    let position: WidgetPosition
    let context: AnalyticsWidgetContext
    
    var id: Int { hashValue }
}
