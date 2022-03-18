import BlocksModels

struct BlockLinkState: Hashable, Equatable {
    let title: String
    let style: Style
    let type: ObjectType?
    let viewType: EditorViewType
    
    let archived: Bool
    let deleted: Bool
    
    init(details: ObjectDetails) {
        self.init(
            title: details.name,
            style: Style(details: details),
            typeUrl: details.type,
            viewType: details.editorViewType,
            archived: details.isArchived,
            deleted: details.isDeleted
        )
    }
    
    init(title: String, style: Style, typeUrl: String?, viewType: EditorViewType, archived: Bool, deleted: Bool) {
        self.title = title
        self.style = style
        self.type = ObjectTypeProvider.objectType(url: typeUrl)
        self.viewType = viewType
        self.archived = archived
        self.deleted = deleted
    }
    
}

extension BlockLinkState {
    
    static let empty = BlockLinkState(title: "", style: .noContent, typeUrl: nil, viewType: .page, archived: false, deleted: false)
    
}
