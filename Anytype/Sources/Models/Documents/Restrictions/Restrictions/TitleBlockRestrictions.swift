//
//  TitleBlockRestrictions.swift
//  Anytype
//
//  Created by Denis Batvinkin on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels


struct TitleBlockRestrictions: BlockRestrictions {
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = true
    let canApplyBackgroundColor = true
    let canApplyMention = true
    let availableAlignments = LayoutAlignment.allCases
    let turnIntoStyles: [BlockViewType] = []
}
