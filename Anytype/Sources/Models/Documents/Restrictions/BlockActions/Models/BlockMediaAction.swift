import BlocksModels

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
            return ImageName.slashMenu.media.file
        case .pictre:
            return ImageName.slashMenu.media.picture
        case .video:
            return ImageName.slashMenu.media.video
        case .bookmark:
            return ImageName.slashMenu.media.bookmark
        case .codeSnippet:
            return ImageName.slashMenu.media.code
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
    
    var blockViewsType: BlockContentType {
        switch self {
        case .file:
            return .file(.file)
        case .pictre:
            return .file(.image)
        case .video:
            return .file(.video)
        case .bookmark:
            return .bookmark(.page)
        case .codeSnippet:
            return .text(.code)
        }
    }
}
