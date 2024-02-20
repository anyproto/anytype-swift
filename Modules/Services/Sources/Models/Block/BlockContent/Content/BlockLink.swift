import AnytypeCore

public extension BlockLink {

    enum IconSize: Int, CaseIterable {
        case none
        case small
        case medium

        public var hasIcon: Bool {
            guard case .none = self else { return true }
            return false
        }
    }

    enum CardStyle: Int, CaseIterable {
        case text
        case card
    }

    enum Description: Int, CaseIterable {
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
        case type
        case cover
    }

    struct Appearance: Hashable {
        public var iconSize: IconSize
        public var cardStyle: CardStyle
        public var description: Description
        public var relations: [Relation]

        public init(iconSize: BlockLink.IconSize, cardStyle: BlockLink.CardStyle, description: BlockLink.Description, relations: [Relation]) {
            self.iconSize = iconSize
            self.cardStyle = cardStyle
            self.description = description
            self.relations = relations
        }
    }
}

public struct BlockLink: Hashable, Equatable {
    public var targetBlockID: String
    public var appearance: Appearance
    
    public init(targetBlockID: String,
                appearance: Appearance) {
        self.targetBlockID = targetBlockID
        self.appearance = appearance
    }
    
    public static func empty(targetBlockID: String = "") -> BlockLink {
        BlockLink(
            targetBlockID: targetBlockID,
            appearance: .init(iconSize: .medium, cardStyle: .card, description: .content, relations: [.name])
        )
    }
}
