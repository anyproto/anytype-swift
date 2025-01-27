import Services
import AnytypeCore

enum ObjectTypeSection: String, CaseIterable, Codable {
    case all
    case pages
    case lists
    case media
    case bookmarks
    case files
    case types
    
    static var searchSupportedSection: [ObjectTypeSection] {
        if FeatureFlags.primitives {
            return allCases
        } else {
            return allCases.filter { $0 != .types }
        }
    }
    
    static var allContentSupportedSections: [ObjectTypeSection] {
        let supportedSections = allCases.filter { $0 != .all }
        if FeatureFlags.primitives {
            return supportedSections
        } else {
            return supportedSections.filter { $0 != .types }
        }
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
        case .types:
            Loc.types
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
        case .types:
            [.objectType]
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
        case .types:
            "Type"
        }
    }
}
