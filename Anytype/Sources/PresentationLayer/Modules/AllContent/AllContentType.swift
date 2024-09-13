import Services

enum AllContentType: CaseIterable {
    case objects
    case files
    case bookmarks
    
    var title: String {
        switch self {
        case .objects:
            Loc.objects
        case .files:
            Loc.files
        case .bookmarks:
            Loc.bookmarks
        }
    }
    
    var supportedLayouts: [DetailsLayout] {
        switch self {
        case .objects:
            return DetailsLayout.visibleLayouts
        case .files:
            return DetailsLayout.fileLayouts
        case .bookmarks:
            return [.bookmark]
        }
    }
}
