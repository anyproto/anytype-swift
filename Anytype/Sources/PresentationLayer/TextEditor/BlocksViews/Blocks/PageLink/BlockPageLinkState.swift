import BlocksModels

extension BlockPageLinkState {
    enum Style: Hashable, Equatable {
        case noContent
        case emoji(String)
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
            style: style(emoji: pageDetails.iconEmoji)
        )
        
        func style(emoji: String?) -> Style {
            guard let emoji = emoji else {
                return .noContent
            }
            guard !emoji.isEmpty else {
                return .noContent
            }
            
            return .emoji(emoji)
        }
    }
    
    init(archived: Bool, title: String, style: Style) {
        self.archived = archived
        self.title = title
        self.style = style
    }
}
