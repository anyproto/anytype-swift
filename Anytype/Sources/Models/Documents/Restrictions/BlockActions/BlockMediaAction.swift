
enum BlockMediaAction: CaseIterable {
    case file
    case pictre
    case video
    case bookmark
    case codeSnippet
    
    var title: String {
        switch self {
        case .file:
            return "File".localized
        case .pictre:
            return "Picture".localized
        case .video:
            return "Video".localized
        case .bookmark:
            return "Bookmark".localized
        case .codeSnippet:
            return "Code snippet".localized
        }
    }
    
    var iconName: String {
        switch self {
        case .file:
            return "TextEditor/Toolbar/Blocks/File"
        case .pictre:
            return "TextEditor/Toolbar/Blocks/Media"
        case .video:
            return "TextEditor/Toolbar/Blocks/Video"
        case .bookmark:
            return "TextEditor/Toolbar/Blocks/Bookmark"
        case .codeSnippet:
            return "TextEditor/Toolbar/Blocks/CodeSnippet"
        }
    }
    
    var subtitle: String {
        switch self {
        case .file:
            return "File block subtitle".localized
        case .pictre:
            return "Picture block subtitle".localized
        case .video:
            return "Video block subtitle".localized
        case .bookmark:
            return "Bookmark block subtitle".localized
        case .codeSnippet:
            return "Code block subtitle".localized
        }
    }
    
    var blockViewsType: BlockViewType {
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
