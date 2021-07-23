//
//  ImageCacheExtension.swift
//  Anytype
//
//  Created by Konstantin Mordan on 21.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Kingfisher

extension Kingfisher.ImageCache {
    
    static let originalImagesCache = Kingfisher.ImageCache(
        name: "io.anytype.kingfisher.originalImagesCache"
    )
    
}
