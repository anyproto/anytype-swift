//
//  ObjectCover.swift
//  ObjectCover
//
//  Created by Konstantin Mordan on 09.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit.UIColor

enum ObjectCover: Hashable {
    case cover(DocumentCover)
    case preview(UIImage?)
}
