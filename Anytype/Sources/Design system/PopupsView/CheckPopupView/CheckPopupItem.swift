//
//  CheckPopupItem.swift
//  Anytype
//
//  Created by Denis Batvinkin on 01.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

struct CheckPopupItem: Identifiable, Hashable {
    let id: String
    let iconAsset: ImageAsset?
    let title: String
    let subtitle: String?
    let isSelected: Bool
}
