//
//  ImageID.swift
//  ImageID
//
//  Created by Konstantin Mordan on 30.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

struct ImageID {
    let id: String
    let width: UrlResolver.ImageWidth
    
    init(id: String, width: UrlResolver.ImageWidth = .thumbnail) {
        self.id = id
        self.width = width
    }
}

extension ImageID {
    
    var resolvedUrl: URL? {
        UrlResolver.resolvedUrl(.image(id: id, width: width))
    }
    
}
