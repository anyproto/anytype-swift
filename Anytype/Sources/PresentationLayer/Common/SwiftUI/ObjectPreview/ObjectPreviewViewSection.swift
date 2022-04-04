//
//  ObjectPreviewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 25.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectPreviewViewSection {
    let main: [ObjectPreviewViewMainSectionItem]
    let featuredRelation: [ObjectPreviewViewFeaturedSectionItem]
}

struct ObjectPreviewViewMainSectionItem: Identifiable {
    enum Value {
        case layout(ObjectPreviewFields.Layout)
        case icon(ObjectPreviewFields.Icon)

        var name: String {
            switch self {
            case .layout(let layout):
                return layout.name
            case .icon(let icon):
                return icon.name
            }
        }
    }

    let id: String
    let name: String
    let value: Value
}

struct ObjectPreviewViewFeaturedSectionItem: Identifiable {
    let id: String
    let iconName: String
    let name: String
    let isEnabled: Bool
}
