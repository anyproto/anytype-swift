import Foundation
import Services

// TODO: Delete with FeatureFlags.widgetCreateWithoutType
struct WidgetTypeCreateData: Identifiable, Hashable {
    let widgetObjectId: String
    let source: WidgetSource
    let position: WidgetPosition
    let context: AnalyticsWidgetContext
    @EquatableNoop var onFinish: () -> Void
    
    var id: Int { hashValue }
}
