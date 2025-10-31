import Services


extension DetailsLayout {
    
    var iconAsset: ImageAsset {
        switch self {
        case .basic:
            return .Layout.basic
        case .profile, .participant:
            return .Layout.profile
        case .todo:
            return .Layout.task
        case .note:
            return .Layout.note
        case .set, .collection, .bookmark, .space, .file, .image, .objectType, .UNRECOGNIZED, .relation,
                .relationOption, .dashboard, .relationOptionsList, .pdf, .audio,
                .video, .date, .spaceView, .tag, .chatDeprecated, .chatDerived, .notification,
                .missingObject, .devices:
            return .noImage
        }
    }
    
    var title: String {
        switch self {
        case .basic:
            return Loc.basic
        case .profile, .participant:
            return Loc.profile
        case .todo:
            return Loc.task
        case .note:
            return Loc.note
        case .set:
            return Loc.set
        case .collection:
            return Loc.collection
        case .bookmark, .space, .file, .image, .objectType, .UNRECOGNIZED, .relation,
                .relationOption, .dashboard, .relationOptionsList, .pdf, .audio,
                .video, .date, .spaceView, .tag, .chatDeprecated, .chatDerived, .notification,
                .missingObject, .devices:
            return ""
        }
    }
    
    var description: String {
        switch self {
        case .basic:
            return Loc.standardLayoutForCanvasBlocks
        case .profile, .participant:
            return Loc.companiesContactsFriendsAndFamily
        case .todo:
            return Loc.actionFocusedLayoutWithACheckbox
        case .note:
            return Loc.designedToCaptureThoughtsQuickly
        case .set, .collection:
            return Loc.collectionOfObjects
        case .bookmark, .space, .file, .image, .objectType, .UNRECOGNIZED, .relation,
                .relationOption, .dashboard, .relationOptionsList, .pdf, .audio,
                .video, .date, .spaceView, .tag, .chatDeprecated, .chatDerived, .notification,
                .missingObject, .devices:
            return ""
        }
    }
    
}
