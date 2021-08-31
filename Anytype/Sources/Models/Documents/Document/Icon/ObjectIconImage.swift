//
//  ObjectIconImage.swift
//  ObjectIconImage
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

enum ObjectIconImage: Hashable {
    case icon(ObjectIconType)
    case todo(Bool)
    case placeholder(Character?)
}
