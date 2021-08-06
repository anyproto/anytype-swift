//
//  ObjectIcon.swift
//  Anytype
//
//  Created by Konstantin Mordan on 06.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit.UIImage
import BlocksModels

enum ObjectIcon: Hashable {
    case icon(DocumentIconType)
    case preview(ObjectIconPreviewType)
}

enum ObjectIconPreviewType: Hashable {
    case basic(UIImage?)
    case profile(UIImage?)
}
