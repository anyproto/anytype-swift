import Services

enum SlashActionMedia: CaseIterable {
    case image
    case file
    case video
    case camera
    case scanDocuments
    case audio
    case bookmark
    case codeSnippet
    
    var title: String {
        switch self {
        case .file:
            Loc.file(1)
        case .image:
            Loc.imageFromPhotoLibrary
        case .video:
            Loc.video(1)
        case .camera:
            Loc.cameraBlockTitle
        case .scanDocuments:
            Loc.scanDocuments
        case .audio:
            Loc.audio(1)
        case .bookmark:
            Loc.bookmark(1)
        case .codeSnippet:
            Loc.codeSnippet
        }
    }
    
    var iconAsset: ImageAsset {
        switch self {
        case .file:
            .X40.attachment
        case .image:
            .X40.picture
        case .video:
            .X40.video
        case .camera:
            .X40.camera
        case .scanDocuments:
            .X40.scanDocuments
        case .audio:
            .X40.audio
        case .bookmark:
            .X40.bookmark
        case .codeSnippet:
            .X40.codeSnippet
        }
    }
    
    var subtitle: String {
        switch self {
        case .file:
            Loc.fileBlockSubtitle
        case .image:
            Loc.imageBlockSubtitle
        case .video:
            Loc.videoBlockSubtitle
        case .camera:
            Loc.cameraBlockSubtitle
        case .scanDocuments:
            Loc.scanDocumentsBlockSubtitle
        case .audio:
            Loc.uploadPlayableAudio
        case .bookmark:
            Loc.bookmarkBlockSubtitle
        case .codeSnippet:
            Loc.codeBlockSubtitle
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
        case .camera:
            return .file(FileBlockContentData(contentType: .image))
        case .scanDocuments:
            return .file(FileBlockContentData(contentType: .image))
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
        case .camera:
            return [Loc.camera, Loc.photo, Loc.picture, Loc.video(1)]
        case .scanDocuments:
            return [Loc.camera]
        default:
            return []
        }
    }
}
