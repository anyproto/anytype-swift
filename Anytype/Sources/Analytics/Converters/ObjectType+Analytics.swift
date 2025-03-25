import Foundation
import Services

extension WidgetSource {
    var analyticsSource: AnalyticsWidgetSource {
        switch self {
        case .object(let objectDetails):
            return .object(type: objectDetails.objectType.analyticsType)
        case .library(let anytypeWidgetId):
            return anytypeWidgetId.analyticsSource
        }
    }
}

extension AnytypeWidgetId {
    var analyticsSource: AnalyticsWidgetSource {
        switch self {
        case .favorite:
            return .favorites
        case .recent:
            return .recent
        case .recentOpen:
            return .recentOpen
        case .sets:
            return .sets
        case .collections:
            return .collections
        case .bin:
            return .bin
        }
    }
}

extension ObjectType {
    var analyticsType: AnalyticsObjectType {
        sourceObject.isNotEmpty ? .object(typeId: sourceObject) : .custom
    }
}

extension ObjectDetails {
    var analyticsType: AnalyticsObjectType {
        objectType.analyticsType
    }
    
    var templateType: AnalyticsObjectType {
        templateIsBundled ? .object(typeId: id) : .custom
    }
}
