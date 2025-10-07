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
        case .allObjects:
            return .allObjects
        case .pinned:
            return .pinned
        case .recent:
            return .recent
        case .recentOpen:
            return .recentOpen
        case .bin:
            return .bin
        case .chat:
            return .chat
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
