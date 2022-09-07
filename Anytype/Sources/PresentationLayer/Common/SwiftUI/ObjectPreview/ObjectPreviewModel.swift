//
//  ObjectPreviewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 25.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import BlocksModels
import OrderedCollections


struct ObjectPreviewModel {

    let iconSize: IconSize
    let cardStyle: CardStyle
    let description: Description

    let relations: [ListItem]

    init(iconSize: ObjectPreviewModel.IconSize,
         cardStyle: ObjectPreviewModel.CardStyle,
         description: ObjectPreviewModel.Description,
         relations: [ObjectPreviewModel.ListItem]) {
        self.iconSize = iconSize
        self.cardStyle = cardStyle
        self.description = description
        self.relations = relations
    }

    init(linkApperance: BlockLink.Appearance) {
        self.iconSize = IconSize(linkApperance.iconSize)
        self.cardStyle = CardStyle(linkApperance.cardStyle)
        self.description = Description(linkApperance.description)
        self.relations = ObjectPreviewModel.buildRealtions(linkApperance: linkApperance)
    }

    var asBlockLinkAppearance: BlockLink.Appearance {
        let relations: [BlockLink.Relation] = relations.compactMap { item in
            guard let relation = item.relation, relation.isEnabled else { return nil }

            return BlockLink.Relation(rawValue: relation.key)
        }

        return BlockLink.Appearance(iconSize: iconSize.asBlockLink,
                                    cardStyle: cardStyle.asBlockLink,
                                    description: description.asBlockLink,
                                    relations: relations)
    }

    private static func buildRealtions(linkApperance: BlockLink.Appearance) -> [ListItem] {
        let nameRelation = Relation(key: BundledRelationKey.name.rawValue,
                                    name: Loc.name,
                                    iconAsset: RelationFormat.shortText.iconAsset,
                                    isLocked: true,
                                    isEnabled: linkApperance.relations.contains(.name))
        let typeRelation = Relation(key: BundledRelationKey.type.rawValue,
                                    name: Loc.LinkAppearance.ObjectType.title,
                                    iconAsset: RelationFormat.object.iconAsset,
                                    isLocked: false,
                                    isEnabled: linkApperance.relations.contains(.type))

        return [.relation(nameRelation), .description, .relation(typeRelation)]
    }
}

extension ObjectPreviewModel {

    enum ListItem: Hashable {
        case relation(Relation)
        case description

        var relation: Relation? {
            guard case let .relation(relation) = self else {
                return nil
            }
            return relation
        }
    }

    struct Relation: Hashable, Identifiable {
        var id: String {
            return key
        }
        let key: String
        let name: String
        let iconAsset: ImageAsset
        let isLocked: Bool
        var isEnabled: Bool
    }
}

extension ObjectPreviewModel {
    enum IconSize: String, CaseIterable {
        case none
        case small
        case medium

        init(_ iconSize: BlockLink.IconSize) {
            switch iconSize {
            case .none:
                self = .none
            case .small:
                self = .small
            case .medium:
                self = .medium
            }
        }

        var asBlockLink: BlockLink.IconSize {
            switch self {
            case .none:
                return.none
            case .small:
                return .small
            case .medium:
                return .medium
            }
        }

        var name: String {
            switch self {
            case .none:
                return Loc.none
            case .small:
                return Loc.small
            case .medium:
                return Loc.medium
            }
        }

        var hasIcon: Bool {
            guard case .none = self else {
                return true
            }
            return false
        }
    }

    enum CardStyle: String, CaseIterable {
        case text
        case card

        init(_ cardStyle: BlockLink.CardStyle) {
            switch cardStyle {
            case .text:
                self = .text
            case .card:
                self = .card
            }
        }

        var asBlockLink: BlockLink.CardStyle {
            switch self {
            case .text:
                return .text
            case .card:
                return .card
            }
        }

        var name: String {
            switch self {
            case .text:
                return Loc.text
            case .card:
                return Loc.card
            }
        }

        var iconAsset: ImageAsset {
            switch self {
            case .text:
                return .text
            case .card:
                return .card
            }
        }
    }

    enum Description: String, CaseIterable, Hashable {
        case none
        case added
        case content

        init(_ description: BlockLink.Description) {
            switch description {
            case .none:
                self = .none
            case .added:
                self = .added
            case .content:
                self = .content
            }
        }

        var asBlockLink: BlockLink.Description {
            switch self {
            case .none:
                return.none
            case .added:
                return .added
            case .content:
                return .content
            }
        }

        var name: String {
            switch self {
            case .none:
                return Loc.LinkAppearance.Description.None.title
            case .added:
                return Loc.LinkAppearance.Description.Added.title
            case .content:
                return Loc.LinkAppearance.Description.Content.title
            }
        }

        var iconAsset: ImageAsset {
            RelationFormat.longText.iconAsset
        }

        var subtitle: String {
            switch self {
            case .none:
                return Loc.LinkAppearance.Description.None.subtitle
            case .added:
                return Loc.LinkAppearance.Description.Added.subtitle
            case .content:
                return Loc.LinkAppearance.Description.Content.subtitle
            }
        }
    }

}
