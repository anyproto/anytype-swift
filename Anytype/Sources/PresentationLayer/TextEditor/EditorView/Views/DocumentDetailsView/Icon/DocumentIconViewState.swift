//
//  DocumentIconViewState.swift
//  Anytype
//
//  Created by Konstantin Mordan on 01.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit.UIImage

enum DocumentIconViewState: Hashable {
    case icon(DocumentIcon)
    case preview(UIImage?)
    case placeholder(Character)
    case empty
}
