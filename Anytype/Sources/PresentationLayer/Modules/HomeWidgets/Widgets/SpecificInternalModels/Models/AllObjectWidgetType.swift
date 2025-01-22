import Foundation

enum AllObjectWidgetType: String {
    case pages
    case lists
    case media
    case bookmarks
    case files
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
        case .bookmarks:
            Loc.bookmarks
        case .files:
            Loc.files
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
        case .bookmarks:
            .bookmarks(spaceId: spaceId)
        case .files:
            .files(spaceId: spaceId)
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
        case .bookmarks:
            .bookmarks
        case .files:
            .files
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
        case .bookmarks:
            .bookmarks
        case .files:
            .files
        }
    }
}
