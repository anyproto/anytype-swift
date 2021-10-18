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
    static let empty = BlockLinkState(archived: false, title: "", style: .noContent, typeUrl: nil)

    let archived: Bool
    let title: String
    let style: Style
    let type: ObjectType?
    
    init(pageDetails: ObjectDetails) {
        self.init(
            archived: pageDetails.isArchived ?? false,
            title: pageDetails.name ?? "",
            style: Style(details: pageDetails),
            typeUrl: pageDetails.type
        )
    }
    
    init(archived: Bool, title: String, style: Style, typeUrl: String?) {
        self.archived = archived
        self.title = title
        self.style = style
        self.type = ObjectTypeProvider.objectType(url: typeUrl)
    }
    
}
