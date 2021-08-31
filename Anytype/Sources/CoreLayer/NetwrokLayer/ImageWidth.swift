//
//  ImageWidth.swift
//  Anytype
//
//  Created by Konstantin Mordan on 31.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum ImageWidth {
    case custom(CGFloat)
    case original
}

extension CGFloat {
    
    var asImageWidth: ImageWidth {
        ImageWidth.custom(self)
    }
    
}
