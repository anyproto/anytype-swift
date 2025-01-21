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
    
    func editorScreenData(spaceId: String) -> EditorScreenData {
        switch self {
        case .pages:
            return .pages(spaceId: spaceId)
        }
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
