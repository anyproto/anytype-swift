
enum BlockMediaAction: CaseIterable {
    case file
    case pictre
    case video
    case bookmark
    case codeSnippet
    
    var blockViewsType: BlocksViews.Toolbar.BlocksTypes {
        switch self {
        case .file:
            return .objects(.file)
        case .pictre:
            return .objects(.picture)
        case .video:
            return .objects(.video)
        case .bookmark:
            return .objects(.bookmark)
        case .codeSnippet:
            return .other(.code)
        }
    }
}
