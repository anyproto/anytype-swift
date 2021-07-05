//
//  DocumentIconViewState.swift
//  Anytype
//
//  Created by Konstantin Mordan on 01.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit.UIImage
import BlocksModels

enum DocumentIconViewState: Hashable {
    case icon(DocumentIcon, DetailsLayout)
    case preview(UIImage?, DetailsLayout)
    case placeholder(Character, DetailsLayout)
    case empty
}
