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
    let id: String
    let name: String
    let value: String
}

struct ObjectPreviewViewFeaturedSectionItem: Identifiable {
    let id: String
    let icon: Image
    let name: String
    let isEnabled: Bool
}
