import BlocksModels

extension BlockLinkState {
    
    enum Style: Hashable, Equatable {
        case noContent
        case icon(ObjectIconType)
        case checkmark(Bool)
        
        init(details: ObjectDetails) {
            if let objectIcon = details.icon {
                self = .icon(objectIcon)
                return
            }
            
            guard case .todo = details.layout else {
                self = .noContent
                return
            }
            
            self = .checkmark(details.isDone)
        }
    }
    
}

struct BlockLinkState: Hashable, Equatable {
    static let empty = BlockLinkState(title: "", style: .noContent, typeUrl: nil, viewType: .page, archived: false, deleted: false)

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
