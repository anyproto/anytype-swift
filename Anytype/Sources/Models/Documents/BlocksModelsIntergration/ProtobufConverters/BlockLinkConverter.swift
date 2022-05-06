import BlocksModels
import ProtobufMessages

// MARK: - BlockContent

extension Anytype_Model_Block.Content.Link {
    var blockContent: BlockContent? {
        let relations = relations.compactMap(BlockLink.Relation.init(rawValue:))

        return .link(
            BlockLink(targetBlockID: targetBlockID,
                      iconSize: iconSize.asModel,
                      cardStyle: cardStyle.asModel,
                      description: description_p.asModel,
                      relations: Set(relations),
                      fields: fields.fields)
        )
    }
}

extension BlockLink {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        let relations = relations.map(\.rawValue)

        return .link(
            .init(targetBlockID: targetBlockID,
                  style: .page, // deprecated
                  fields: [:],
                  iconSize: iconSize.asMiddleware,
                  cardStyle: cardStyle.asMiddleware,
                  description_p: description.asMiddleware,
                  relations: relations)
        )
    }
}

// MARK: - IconSize

extension Anytype_Model_Block.Content.Link.IconSize {
    var asModel: BlockLink.IconSize {
        switch self {
        case .small: return .small
        case .medium: return .medium
        case .UNRECOGNIZED: return .small
        }
    }
}

extension BlockLink.IconSize {
    var asMiddleware: Anytype_Model_Block.Content.Link.IconSize {
        switch self {
        case .small: return .small
        case .medium: return .medium
        }
    }
}

// MARK: - CardStyle

extension Anytype_Model_Block.Content.Link.CardStyle {
    var asModel: BlockLink.CardStyle {
        switch self {
        case .text: return .text
        case .card: return .card
        case .inline: return .inline
        case .UNRECOGNIZED: return .text
        }
    }
}

extension BlockLink.CardStyle {
    var asMiddleware: Anytype_Model_Block.Content.Link.CardStyle {
        switch self {
        case .text: return .text
        case .card: return .card
        case .inline: return .inline
        }
    }
}

// MARK: - Description

extension Anytype_Model_Block.Content.Link.Description {
    var asModel: BlockLink.Description {
        switch self {
        case .none: return .none
        case .added: return .added
        case .content: return .content
        case .UNRECOGNIZED: return .none
        }
    }
}

extension BlockLink.Description {
    var asMiddleware: Anytype_Model_Block.Content.Link.Description {
        switch self {
        case .none: return .none
        case .added: return .added
        case .content: return .content
        }
    }
}

extension ObjectPreviewFields {

    static func createDefaultFieldsForBlockLink() -> ObjectPreviewFields {
        .init(icon: .medium, layout: .text, withName: true, featuredRelationsIds: [])
    }
}
