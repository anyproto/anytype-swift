import Services

enum SlashActionSingle: CaseIterable {
    case camera
    case linkTo
    
    var title: String {
        switch self {
        case .camera:
            return Loc.cameraBlockTitle
        case .linkTo:
            return Loc.addLink
        }
    }
    
    var iconAsset: ImageAsset {
        switch self {
        case .camera:
            return .X24.camera
        case .linkTo:
            return .X24.linkToExistingObject
        }
    }
    
    var blockViewsType: BlockContentType {
        switch self {
        case .camera:
            return .file(FileBlockContentData(contentType: .image))
        case .linkTo:
            return .bookmark(.page)
        }
    }
    
    var titleSynonyms: [String] {
        switch self {
        case .camera:
            return [Loc.camera, Loc.photo, Loc.picture, Loc.video(1)]
        case .linkTo:
            return []
        }
    }
}