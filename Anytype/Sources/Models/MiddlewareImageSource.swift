//
//  MiddlewareImageSource.swift
//  Anytype
//
//  Created by Konstantin Mordan on 21.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

struct MiddlewareImageSource {
    let id: String
    let width: UrlResolver.ImageWidth
    
    init(id: String, width: UrlResolver.ImageWidth = .thumbnail) {
        self.id = id
        self.width = width
    }
}

extension MiddlewareImageSource {
    
    var resolvedUrl: URL? {
        return UrlResolver.resolvedUrl(.image(id: id, width: width))
    }
    
}
