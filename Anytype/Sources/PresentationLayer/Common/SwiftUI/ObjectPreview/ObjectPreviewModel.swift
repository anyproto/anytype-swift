//
//  ObjectPreviewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 25.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Services

struct ObjectPreviewModel {
    var cardStyle: BlockLink.CardStyle
    var iconSize: BlockLink.IconSize
    var description: BlockLink.Description
    var coverRelation: Relation?
    var isCoverRelationEnabled: Bool
    var isIconMenuVisible: Bool
    
    var relations: [ListItem]

    init(linkState: BlockLinkState) {
        self.relations = Self.buildRealtions(relations: linkState.relations)
        self.cardStyle = linkState.cardStyle
        self.isIconMenuVisible = linkState.objectLayout != .todo
        self.iconSize = linkState.iconSize
        self.description = linkState.descriptionState
        self.isCoverRelationEnabled = linkState.relations.contains(.cover)

        setupCoverRelation()
    }

    var asBlockLinkAppearance: BlockLink.Appearance {
        var relations: [BlockLink.Relation] = relations.compactMap { item in
            guard let relation = item.relation, relation.isEnabled else { return nil }

            return BlockLink.Relation(rawValue: relation.key)
        }

        if let coverRelation = coverRelation, coverRelation.isEnabled {
            relations.append(.cover)
        }

        return BlockLink.Appearance(
            iconSize: iconSize,
            cardStyle: cardStyle,
            description: description,
            relations: relations
        )
    }

    mutating func setupCoverRelation() {
        switch cardStyle {
        case .card:
            self.coverRelation = Relation(
                key: BundledPropertyKey.coverType.rawValue,
                name: Loc.cover,
                iconAsset: nil,
                isLocked: false,
                isEnabled: isCoverRelationEnabled
            )
        case .text:
            self.coverRelation = nil
        }
    }

    private static func buildRealtions(relations: [BlockLink.Relation]) -> [ListItem] {
        let nameRelation = Relation(key: BundledPropertyKey.name.rawValue,
                                    name: Loc.name,
                                    iconAsset: RelationFormat.shortText.iconAsset,
                                    isLocked: true,
                                    isEnabled: relations.contains(.name))
        let typeRelation = Relation(key: BundledPropertyKey.type.rawValue,
                                    name: Loc.LinkAppearance.ObjectType.title,
                                    iconAsset: RelationFormat.object.iconAsset,
                                    isLocked: false,
                                    isEnabled: relations.contains(.type))

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
        let iconAsset: ImageAsset?
        let isLocked: Bool
        var isEnabled: Bool
    }
}

extension BlockLink.IconSize {
    var name: String {
        switch self {
        case .none:
            return Loc.BlockLink.PreviewSettings.IconSize.none
        case .small:
            return Loc.BlockLink.PreviewSettings.IconSize.small
        case .medium:
            return Loc.BlockLink.PreviewSettings.IconSize.medium
        }
    }

    var hasIcon: Bool {
        guard case .none = self else {
            return true
        }
        return false
    }
}

extension BlockLink.CardStyle {
    var name: String {
        switch self {
        case .text:
            return Loc.BlockLink.PreviewSettings.Layout.Text.title
        case .card:
            return Loc.BlockLink.PreviewSettings.Layout.Card.title
        }
    }

    var iconAsset: ImageAsset {
        switch self {
        case .text:
            return .Preview.text
        case .card:
            return .Preview.card
        }
    }
}

extension BlockLink.Description {
    var name: String {
        switch self {
        case .none:
            return Loc.LinkAppearance.Description.None.title
        case .added:
            return Loc.LinkAppearance.Description.Object.title
        case .content:
            return Loc.LinkAppearance.Description.Content.title
        }
    }

    var iconAsset: ImageAsset {
        RelationFormat.longText.iconAsset
    }
}
