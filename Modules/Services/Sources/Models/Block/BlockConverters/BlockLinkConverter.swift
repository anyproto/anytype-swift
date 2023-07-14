import ProtobufMessages

// MARK: - BlockContent

public extension Anytype_Model_Block.Content.Link {
    var blockContent: BlockContent? {
        let relations = relations.compactMap(BlockLink.Relation.init(rawValue:))

        return .link(
            BlockLink(
                targetBlockID: targetBlockID,
                appearance: .init(
                    iconSize: iconSize.asModel,
                    cardStyle: cardStyle.asModel,
                    description: description_p.asModel,
                    relations: relations
                )
            )
        )
    }
}

public extension BlockLink {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        let relations = appearance.relations.map(\.rawValue)

        return .link(.with {
            $0.targetBlockID = targetBlockID
            $0.style = .page // deprecated
            $0.fields = [:]
            $0.iconSize = appearance.iconSize.asMiddleware
            $0.cardStyle = appearance.cardStyle.asMiddleware
            $0.description_p = appearance.description.asMiddleware
            $0.relations = relations
        })
    }
}

// MARK: - IconSize

public extension Anytype_Model_Block.Content.Link.IconSize {
    var asModel: BlockLink.IconSize {
        switch self {
        case .sizeSmall: return .small
        case .sizeMedium: return .medium
        case .sizeNone: return .none
        case .UNRECOGNIZED: return .none
        }
    }
}

public extension BlockLink.IconSize {
    var asMiddleware: Anytype_Model_Block.Content.Link.IconSize {
        switch self {
        case .small: return .sizeSmall
        case .medium: return .sizeMedium
        case .none: return .sizeNone
        }
    }
}

// MARK: - CardStyle

public extension Anytype_Model_Block.Content.Link.CardStyle {
    var asModel: BlockLink.CardStyle {
        switch self {
        case .text: return .text
        case .card: return .card
        case .inline: return .card // add .inline when will be supported
        case .UNRECOGNIZED: return .text
        }
    }
}

public extension BlockLink.CardStyle {
    var asMiddleware: Anytype_Model_Block.Content.Link.CardStyle {
        switch self {
        case .text: return .text
        case .card: return .card
        }
    }
}

// MARK: - Description

public extension Anytype_Model_Block.Content.Link.Description {
    var asModel: BlockLink.Description {
        switch self {
        case .none: return .none
        case .added: return .added
        case .content: return .content
        case .UNRECOGNIZED: return .none
        }
    }
}

public extension BlockLink.Description {
    var asMiddleware: Anytype_Model_Block.Content.Link.Description {
        switch self {
        case .none: return .none
        case .added: return .added
        case .content: return .content
        }
    }
}
