import Services
import AnytypeCore

extension ScreenData {
    init(
        details: ObjectDetails,
        mode: DocumentMode = .handling,
        blockId: String? = nil,
        activeViewId: String? = nil,
        openMediaFileAsObject: Bool = false,
        usecase: ObjectHeaderEmptyUsecase = .full
    ) {
        let page: EditorScreenData = .page(EditorPageObject(
            details: details,
            mode: mode,
            blockId: blockId,
            usecase: usecase
        ))
        
        switch details.editorViewType {
        case .page:
            self = .editor(page)
        case .list:
            self = .editor(.list(EditorListObject(
                details: details,
                activeViewId: activeViewId,
                mode: mode,
                usecase: usecase
            )))
        case .date:
            self = .editor(.date(EditorDateObject(date: details.timestamp, spaceId: details.spaceId)))
        case .type:
            self = .editor(.type(EditorTypeObject(objectId: details.id, spaceId: details.spaceId)))
        case .participant:
            self = .alert(.spaceMember(ObjectInfo(objectId: details.id, spaceId: details.spaceId)))
        case .mediaFile:
            if openMediaFileAsObject {
                self = .editor(page)
            } else {
                self = .preview(MediaFileScreenData(items: [details.previewRemoteItem]))
            }
        case .bookmark:
            if let source = details.source {
                self = .bookmark(BookmarkScreenData(url: source.url, editorScreenData: page))
            } else {
                self = .editor(page)
            }
        }
    }
}
