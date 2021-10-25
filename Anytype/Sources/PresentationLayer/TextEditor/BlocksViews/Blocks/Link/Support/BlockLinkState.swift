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
    static let empty = BlockLinkState(title: "", style: .noContent, typeUrl: nil, archived: false, deleted: false)

    let title: String
    let style: Style
    let type: ObjectType?
    
    let archived: Bool
    let deleted: Bool
    
    init(pageDetails: ObjectDetails) {
        self.init(
            title: pageDetails.name,
            style: Style(details: pageDetails),
            typeUrl: pageDetails.type,
            archived: pageDetails.isArchived,
            deleted: pageDetails.isDeleted
        )
    }
    
    init(title: String, style: Style, typeUrl: String?, archived: Bool, deleted: Bool) {
        self.title = title
        self.style = style
        self.type = ObjectTypeProvider.objectType(url: typeUrl)
        self.archived = archived
        self.deleted = deleted
    }
    
}
