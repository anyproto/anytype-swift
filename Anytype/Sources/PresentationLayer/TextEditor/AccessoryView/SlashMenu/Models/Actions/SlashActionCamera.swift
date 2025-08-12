import Services

enum SlashActionCamera: CaseIterable {
    case camera
    
    var title: String {
        Loc.cameraBlockTitle
    }
    
    var iconAsset: ImageAsset {
        .X40.camera
    }
    
    var subtitle: String {
        Loc.cameraBlockSubtitle
    }
    
    var blockViewsType: BlockContentType {
        .file(FileBlockContentData(contentType: .image))
    }
    
    var titleSynonyms: [String] {
        [Loc.camera, Loc.photo, Loc.picture, Loc.video(1)]
    }
}