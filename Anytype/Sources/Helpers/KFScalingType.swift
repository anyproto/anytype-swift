//
//  KFScalingType.swift
//  KFScalingType
//
//  Created by Konstantin Mordan on 30.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import Kingfisher

enum KFScalingType {
    case resizing(Kingfisher.ContentMode)
    case downsampling
}
