
enum TextViewContextMenuOption: CaseIterable, Equatable {
    
    case toggleMarkup(TextAttributesType)
    case setLink
    
    static var allCases: [TextViewContextMenuOption] {
        [
            .toggleMarkup(.bold),
            .toggleMarkup(.italic),
            .toggleMarkup(.strikethrough),
            .toggleMarkup(.keyboard),
            .setLink
        ]
    }
    
    var title: String {
        switch self {
        case let .toggleMarkup(type):
            return type.title
        case .setLink:
            return "Link".localized
        }
    }
}
