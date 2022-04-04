//
//  ObjectPreviewFields.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

struct ObjectPreviewFields {
    enum FieldName {
        public static let withName = "withName"
        public static let withIcon = "withIcon"
        public static let style = "style"
        public static let withDescription = "withDescription"
    }

    enum Layout {
        case text
        case card
    }

    enum Icon {
        case none
        case medium
    }

    let icon: Icon
    let layout: Layout
    let withName: Bool
    let featuredRelationsIds: Set<String>
}

extension ObjectPreviewFields.Layout {

    var name: String {
        switch self {
        case .text:
            return "Text".localized
        case .card:
            return "Card".localized
        }
    }
}

extension ObjectPreviewFields.Icon {

    var name: String {
        switch self {
        case .none:
            return "None".localized
        case .medium:
            return "Medium".localized
        }
    }
}
