import Services
import AnytypeCore

enum AllContentType: String {
    case pages
    case lists
    case media
    case bookmarks
    case files
    case types
    
    static var allSupportedTypes: [AllContentType] {
        var supportedTypes: [AllContentType] = [.pages, .lists, .media, .bookmarks, .files]
        if FeatureFlags.primitives {
            supportedTypes.append(.types)
        }
        return supportedTypes
    }
    
    var title: String {
        switch self {
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
        case .pages:
            "Pages"
        case .lists:
            "Lists"
        case .files:
            "Files"
        case .media:
            "Media"
        case .bookmarks:
            "Bookmarks"
        case .types:
            "Types"
        }
    }
}