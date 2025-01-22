import Foundation

enum AllObjectWidgetType: String {
    case pages
    case lists
    case media
}

extension AllObjectWidgetType {
    var name: String {
        switch self {
        case .pages:
            Loc.pages
        case .lists:
            Loc.lists
        case .media:
            Loc.media
        }
    }
    
    func editorScreenData(spaceId: String) -> EditorScreenData {
        switch self {
        case .pages:
            .pages(spaceId: spaceId)
        case .lists:
            .lists(spaceId: spaceId)
        case .media:
            .media(spaceId: spaceId)
        }
    }
    
    var analyticsWidgetSource: AnalyticsWidgetSource {
        switch self {
        case .pages:
            .pages
        case .lists:
            .lists
        case .media:
            .media
        }
    }
    
    var typeSection: ObjectTypeSection {
        switch self {
        case .pages:
            .pages
        case .lists:
            .lists
        case .media:
            .media
        }
    }
}
