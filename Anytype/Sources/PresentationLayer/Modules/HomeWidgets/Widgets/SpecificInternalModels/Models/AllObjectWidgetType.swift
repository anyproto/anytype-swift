import Foundation

enum AllObjectWidgetType: String {
    case pages
}

extension AllObjectWidgetType {
    var name: String {
        switch self {
        case .pages:
            Loc.pages
        }
    }
    
    var screenData: ScreenData {
        fatalError()
    }
    
    var analyticsWidgetSource: AnalyticsWidgetSource {
        switch self {
        case .pages:
            return .pages
        }
    }
    
    var typeSection: ObjectTypeSection {
        switch self {
        case .pages:
            return .pages
        }
    }
}
