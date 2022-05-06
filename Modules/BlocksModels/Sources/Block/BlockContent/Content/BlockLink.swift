import AnytypeCore
public extension BlockLink {

    enum IconSize {
        case small
        case medium
    }

    enum CardStyle {
        case text
        case card
        case inline
    }

    enum Description {
        case none
        case added
        case content

        public var hasDescription: Bool {
            switch self {
            case .none:
                return false
            case .added, .content:
                return true
            }
        }
    }

    enum Relation: String {
        case name
        case icon
    }
}

public struct BlockLink: Hashable, Equatable {
    public var targetBlockID: String
    public var iconSize: IconSize
    public var cardStyle: CardStyle
    public var description: Description
    public var fields: [String: AnyHashable]
    public var relations: Set<Relation>
    
    public init(targetBlockID: String,
                iconSize: IconSize,
                cardStyle: CardStyle,
                description: Description,
                relations: Set<Relation>,
                fields: [String : AnyHashable]) {
        self.targetBlockID = targetBlockID
        self.fields = fields
        self.iconSize = iconSize
        self.cardStyle = cardStyle
        self.description = description
        self.relations = relations
    }
    
    public static func empty(targetBlockID: String = .empty) -> BlockLink {
        BlockLink(targetBlockID: targetBlockID, iconSize: .small, cardStyle: .text, description: .none, relations: [.name, .icon], fields: [:])
    }
}
