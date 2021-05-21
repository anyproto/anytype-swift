import BlocksModels

/// Struct State that will take care of all flags and data.
/// It is equal semantically to `Payload` that will delivered from outworld ( view model ).
/// It contains necessary information for view as emoji, title, archived, etc.
///
struct BlockPageLinkState {
    /// Visual style of left view ( image or label with emoji ).
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
        static func asOurModel(_ pageDetails: DetailsInformationProvider) -> BlockPageLinkState {
            let archived = false
            var hasContent = false
            let title = pageDetails.name?.value
            let emoji = pageDetails.iconEmoji?.value
            hasContent = !emoji.isNil
            let correctEmoji = emoji.flatMap({$0.isEmpty ? nil : $0})
            return .init(archived: archived, hasContent: hasContent, title: title, emoji: correctEmoji)
        }
    }
    
    static let empty = BlockPageLinkState.init(archived: false, hasContent: false, title: nil, emoji: nil)
    var archived: Bool
    var hasContent: Bool
    var title: String?
    var emoji: String?
    
    var style: Style {
        switch (hasContent, emoji) {
        case (false, .none): return .noContent
        case (true, .none): return .noEmoji
        case let (_, .some(value)): return .emoji(value)
        }
    }
}
