import Services
import AnytypeCore

enum ObjectTypeSection: String, CaseIterable, Codable {
    case all
    case pages
    case lists
    case media
    case bookmarks
    case files
    
    static var searchSupportedSection: [ObjectTypeSection] {
        allCases
    }
    
    static var allObjectsSupportedSections: [ObjectTypeSection] {
        allCases.filter { $0 != .all }
    }
    
    var title: String {
        switch self {
        case .all:
            Loc.all
        case .pages:
            Loc.pages
        case .lists:
            Loc.lists
        case .files:
            Loc.files
        case .media:
            Loc.media
        case .bookmarks:
            Loc.bookmarks
        }
    }
    
    var supportedLayouts: [DetailsLayout] {
        switch self {
        case .all:
            DetailsLayout.visibleLayoutsWithFiles
        case .pages:
            DetailsLayout.editorLayouts
        case .lists:
            DetailsLayout.listLayouts
        case .files:
            DetailsLayout.fileLayouts
        case .media:
            DetailsLayout.mediaLayouts
        case .bookmarks:
            [.bookmark]
        }
    }
    
    var analyticsValue: String {
        switch self {
        case .all:
            "All"
        case .pages:
            "Object"
        case .lists:
            "List"
        case .files:
            "File"
        case .media:
            "Media"
        case .bookmarks:
            "Bookmark"
        }
    }
}
