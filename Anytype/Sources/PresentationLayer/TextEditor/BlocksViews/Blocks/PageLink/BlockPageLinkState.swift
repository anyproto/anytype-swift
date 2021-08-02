import BlocksModels

extension BlockPageLinkState {
    
    enum Style: Hashable, Equatable {
        case noContent
        case icon(DocumentIconType)
        case checkmark(Bool)
        
        init(details: DetailsDataProtocol) {
            if let objectIcon = details.icon {
                self = .icon(objectIcon)
                return
            }
            
            guard case .todo = details.layout else {
                self = .noContent
                return
            }
            
            self = .checkmark(details.done ?? false)
        }
    }
    
}

struct BlockPageLinkState: Hashable, Equatable {
    static let empty = BlockPageLinkState(archived: false, title: "", style: .noContent)

    let archived: Bool
    let title: String
    let style: Style
    
    init(pageDetails: DetailsDataProtocol) {        
        self.init(
            archived: pageDetails.isArchived ?? false,
            title: pageDetails.name ?? "",
            style: Style(details: pageDetails)
        )
    }
    
    init(archived: Bool, title: String, style: Style) {
        self.archived = archived
        self.title = title
        self.style = style
    }
    
}
