import BlocksModels

extension BlockPageLinkState {
    
    enum Style: Hashable, Equatable {
        case noContent
        case icon(DocumentIconType)
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
            style: pageDetails.icon.flatMap { .icon($0) } ?? .noContent
        )
    }
    
    init(archived: Bool, title: String, style: Style) {
        self.archived = archived
        self.title = title
        self.style = style
    }
}
