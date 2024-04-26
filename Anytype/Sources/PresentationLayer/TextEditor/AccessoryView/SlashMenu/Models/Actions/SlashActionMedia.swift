import Services

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
            return .X40.attachment
        case .pictre:
            return .X40.picture
        case .video:
            return .X40.video
        case .audio:
            return .X40.audio
        case .bookmark:
            return .X40.bookmark
        case .codeSnippet:
            return .X40.codeSnippet
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
