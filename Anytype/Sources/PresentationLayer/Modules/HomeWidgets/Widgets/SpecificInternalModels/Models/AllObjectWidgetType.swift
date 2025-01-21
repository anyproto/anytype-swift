import Foundation

enum AllObjectWidgetType: String {
    case pages
    case lists
}

extension AllObjectWidgetType {
    var name: String {
        switch self {
        case .pages:
            Loc.pages
        case .lists:
            Loc.lists
        }
    }
    
    func editorScreenData(spaceId: String) -> EditorScreenData {
        switch self {
        case .pages:
            return .pages(spaceId: spaceId)
        case .lists:
            return .lists(spaceId: spaceId)
        }
    }
    
    var analyticsWidgetSource: AnalyticsWidgetSource {
        switch self {
        case .pages:
            return .pages
        case .lists:
            return .lists
        }
    }
    
    var typeSection: ObjectTypeSection {
        switch self {
        case .pages:
            return .pages
        case .lists:
            return .lists
        }
    }
}
