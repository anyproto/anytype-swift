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
            style: .init(emoji: pageDetails.iconEmoji)
        )
    }
    
    init(archived: Bool, title: String, style: Style) {
        self.archived = archived
        self.title = title
        self.style = style
    }
}

private extension BlockPageLinkState.Style {
    
    init(emoji: String?) {
        guard let emoji = emoji, !emoji.isEmpty else {
            self = .noContent
            return
        }
        
        self = .emoji(emoji)
    }
    
}
