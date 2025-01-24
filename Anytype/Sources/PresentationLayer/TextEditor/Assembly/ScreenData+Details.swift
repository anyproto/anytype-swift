import Services


extension ScreenData {
    init(details: ObjectDetails, mode: DocumentMode = .handling, blockId: String? = nil, activeViewId: String? = nil) {
        switch details.editorViewType {
        case .page:
            self = .editor(.page(EditorPageObject(
                details: details,
                mode: mode,
                blockId: blockId
            )))
        case .list:
            self = .editor(.list(EditorListObject(
                details: details,
                activeViewId: activeViewId,
                mode: mode
            )))
        case .date:
            self = .editor(.date(EditorDateObject(date: details.timestamp, spaceId: details.spaceId)))
        case .type:
            self = .editor(.type(EditorTypeObject(objectId: details.id, spaceId: details.spaceId)))
        case .participant:
            self = .alert(.spaceMember(ObjectInfo(objectId: details.id, spaceId: details.spaceId)))
        case .mediaFile:
            self = .preview(MediaFileScreenData(item: details.previewRemoteItem))
        }
    }
}
