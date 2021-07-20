import BlocksModels

struct BlockPageLinkState: Hashable, Equatable {
    
    enum Style {
        typealias Emoji = String
        case noContent
        case noEmoji
        case emoji(Emoji)
        
        var resource: String {
            switch self {
            case .noContent: return "TextEditor/Style/Page/empty"
            case .noEmoji: return "TextEditor/Style/Page/withoutEmoji"
            case let .emoji(value): return value
            }
        }
    }
    
    enum Converter {
        static func asOurModel(_ pageDetails: DetailsDataProtocol) -> BlockPageLinkState {
            let archived = pageDetails.isArchived ?? false
            var hasContent = false
            let title = pageDetails.name
            let emoji = pageDetails.iconEmoji
            hasContent = !emoji.isNil
            let correctEmoji = emoji.flatMap {$0.isEmpty ? nil : $0}
            
            return BlockPageLinkState(
                archived: archived,
                hasContent: hasContent,
                title: title,
                emoji: correctEmoji
            )
        }
    }
    
    static let empty = BlockPageLinkState.init(archived: false, hasContent: false, title: nil, emoji: nil)

    let archived: Bool
    let hasContent: Bool
    let title: String?
    let emoji: String?
    
    var style: Style {
        switch (hasContent, emoji) {
        case (false, .none): return .noContent
        case (true, .none): return .noEmoji
        case let (_, .some(value)): return .emoji(value)
        }
    }
}
