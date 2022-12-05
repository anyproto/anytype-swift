import BlocksModels

enum SlashActionMedia: CaseIterable {
    case file
    case pictre
    case video
    case audio
    case bookmark
    case codeSnippet
    
    var title: String {
        switch self {
        case .file:
            return Loc.file
        case .pictre:
            return Loc.picture
        case .video:
            return Loc.video
        case .audio:
            return Loc.audio
        case .bookmark:
            return Loc.bookmark
        case .codeSnippet:
            return Loc.codeSnippet
        }
    }
    
    var iconAsset: ImageAsset {
        switch self {
        case .file:
            return .slashMenuMediaFile
        case .pictre:
            return .slashMenuMediaPicture
        case .video:
            return .slashMenuMediaVideo
        case .audio:
            return .slashMenuMediaAudio
        case .bookmark:
            return .slashMenuMediaBookmark
        case .codeSnippet:
            return .slashMenuMediaCode
        }
    }
    
    var subtitle: String {
        switch self {
        case .file:
            return Loc.fileBlockSubtitle
        case .pictre:
            return Loc.pictureBlockSubtitle
        case .video:
            return Loc.videoBlockSubtitle
        case .audio:
            return Loc.uploadPlayableAudio
        case .bookmark:
            return Loc.bookmarkBlockSubtitle
        case .codeSnippet:
            return Loc.codeBlockSubtitle
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
        case .audio:
            return .file(.audio)
        case .bookmark:
            return .bookmark(.page)
        case .codeSnippet:
            return .text(.code)
        }
    }
}
