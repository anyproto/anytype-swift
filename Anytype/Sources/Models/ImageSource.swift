//
//  ImageSource.swift
//  Anytype
//
//  Created by Konstantin Mordan on 21.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import Kingfisher

enum ImageSource {
    case local(UIImage)
    case middleware(MiddlewareImageSource)
}
