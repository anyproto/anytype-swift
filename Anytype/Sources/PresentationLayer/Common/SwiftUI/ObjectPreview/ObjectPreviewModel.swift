//
//  ObjectPreviewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 25.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels


struct ObjectPreviewModel {

    let iconSize: IconSize
    let cardStyle: CardStyle
    let description: Description

    let relations: Set<Relation>

    init(iconSize: ObjectPreviewModel.IconSize,
         cardStyle: ObjectPreviewModel.CardStyle,
         description: ObjectPreviewModel.Description,
         relations: Set<ObjectPreviewModel.Relation>) {
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
        BlockLink.Appearance(iconSize: iconSize.asBlockLink,
                             cardStyle: cardStyle.asBlockLink,
                             description: description.asBlockLink,
                             relations: relations.map(\.key))
    }

    private static func buildRealtions(linkApperance: BlockLink.Appearance) -> Set<Relation> {
        let nameRelation = Relation(key: BundledRelationKey.name.rawValue,
                                    name: "Name".localized,
                                    iconName: RelationMetadata.Format.shortText.iconName,
                                    isLocked: true,
                                    isEnabled: linkApperance.relations.contains(BundledRelationKey.name.rawValue))
        return [nameRelation]
    }
}

extension ObjectPreviewModel {
    struct Relation: Hashable, Identifiable {
        var id: String {
            return key
        }
        let key: String
        let name: String
        let iconName: String
        let isLocked: Bool
        let isEnabled: Bool
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
                return "None".localized
            case .small:
                return "Small".localized
            case .medium:
                return "Medium".localized
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
                return "Text".localized
            case .card:
                return "Card".localized
            }
        }

        var iconName: String {
            switch self {
            case .text:
                return ImageName.ObjectPreview.text
            case .card:
                return ImageName.ObjectPreview.card
            }
        }
    }

    enum Description: String, CaseIterable {
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
                return "LinkAppearance.Description.None.Title".localized
            case .added:
                return "LinkAppearance.Description.Added.Title".localized
            case .content:
                return "LinkAppearance.Description.Content.Title".localized
            }
        }

        var iconName: String {
            RelationMetadata.Format.longText.iconName
        }

        var subtitle: String {
            switch self {
            case .none:
                return "LinkAppearance.Description.None.Subtitle".localized
            case .added:
                return "LinkAppearance.Description.Added.Subtitle".localized
            case .content:
                return "LinkAppearance.Description.Content.Subtitle".localized
            }
        }
    }

}
