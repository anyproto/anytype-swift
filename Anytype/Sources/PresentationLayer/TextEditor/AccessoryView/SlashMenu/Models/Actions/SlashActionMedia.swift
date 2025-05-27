import Services

enum SlashActionMedia: CaseIterable {
    case file
    case image
    case video
    case audio
    case bookmark
    case codeSnippet
    
    var title: String {
        switch self {
        case .file:
            return Loc.file(1)
        case .image:
            return Loc.image(1)
        case .video:
            return Loc.video(1)
        case .audio:
            return Loc.audio(1)
        case .bookmark:
            return Loc.bookmark(1)
        case .codeSnippet:
            return Loc.codeSnippet
        }
    }
    
    var iconAsset: ImageAsset {
        switch self {
        case .file:
            return .X40.attachment
        case .image:
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
        case .image:
            return Loc.imageBlockSubtitle
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
            return .file(FileBlockContentData(contentType: .file))
        case .image:
            return .file(FileBlockContentData(contentType: .image))
        case .video:
            return .file(FileBlockContentData(contentType: .video))
        case .audio:
            return .file(FileBlockContentData(contentType: .audio))
        case .bookmark:
            return .bookmark(.page)
        case .codeSnippet:
            return .text(.code)
        }
    }
    
    var titleSynonyms: [String] {
        switch self {
        case .image:
            return [Loc.picture]
        default:
            return []
        }
    }
}
