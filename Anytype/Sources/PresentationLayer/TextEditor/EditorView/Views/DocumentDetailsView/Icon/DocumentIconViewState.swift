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
    case icon(DocumentIconType)
    case preview(DocumentIconViewPreviewType)
    case empty
}

enum DocumentIconViewPreviewType: Hashable {
    case basic(UIImage?)
    case profile(UIImage?)
}
