import Services
import AnytypeCore

enum AllContentType: String, CaseIterable {
    case objects
    case media
    case bookmarks
    case files
    
    var title: String {
        switch self {
        case .objects:
            Loc.objects
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
        case .objects:
            layouts = DetailsLayout.visibleLayouts
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
