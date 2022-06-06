import AnytypeCore

public extension BlockLink {

    enum IconSize {
        case none
        case small
        case medium

        public var hasIcon: Bool {
            guard case .none = self else { return true }
            return false
        }
    }

    enum CardStyle: CaseIterable {
        case text
        case card
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

    struct Appearance: Hashable {
        public var iconSize: IconSize
        public var cardStyle: CardStyle
        public var description: Description
        public var relations: [String]

        public init(iconSize: BlockLink.IconSize, cardStyle: BlockLink.CardStyle, description: BlockLink.Description, relations: [String]) {
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
    
    public static func empty(targetBlockID: String = .empty) -> BlockLink {
        BlockLink(
            targetBlockID: targetBlockID,
            appearance: .init(iconSize: .small, cardStyle: .text, description: .none, relations: [BundledRelationKey.name.rawValue])
        )
    }
}
