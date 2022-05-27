//
//  ObjectPreviewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 25.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI
import BlocksModels

struct ObjectPreviewViewSection {
    let main: [MainSectionItem]
    let featuredRelation: [FeaturedSectionItem]
}

extension ObjectPreviewViewSection {

    struct MainSectionItem: Identifiable {

        enum IconSize: String, CaseIterable {
            case none
            case medium

            var name: String {
                switch self {
                case .none:
                    return "None".localized
                case .medium:
                    return "Medium".localized
                }
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

            var asModel: BlockLink.CardStyle {
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

        enum Value {
            case layout(CardStyle)
            case icon(IconSize)

            var name: String {
                switch self {
                case .layout(let cardStyle):
                    return cardStyle.name
                case .icon(let icon):
                    return icon.name
                }
            }
        }

        let id: String
        let name: String
        let value: Value
    }
}

extension ObjectPreviewViewSection {

    struct FeaturedSectionItem: Identifiable {
        enum IDs: Identifiable {
            case name
            case description

            var id: Self { return self }
        }

        let id: IDs
        let iconName: String
        let name: String
        let isEnabled: Bool
    }
}
