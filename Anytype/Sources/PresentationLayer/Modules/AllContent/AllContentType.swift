import Services
import AnytypeCore

enum AllContentType: String, CaseIterable {
    case pages
    case lists
    case media
    case bookmarks
    case files
    
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
        }
    }
    
    var supportedLayouts: [DetailsLayout] {
        var layouts = [DetailsLayout]()
        switch self {
        case .pages:
            layouts = DetailsLayout.pageLayouts
        case .lists:
            layouts = DetailsLayout.setLayouts
        case .files:
            layouts = DetailsLayout.fileLayouts
        case .media:
            layouts = DetailsLayout.mediaLayouts
        case .bookmarks:
            layouts = [.bookmark]
        }
        return layouts - [.participant]
    }
}
