//
//  ImageID.swift
//  ImageID
//
//  Created by Konstantin Mordan on 30.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import  UIKit

struct ImageID {
    private let id: String
    private let width: ImageWidth
    
    init(id: String, width: ImageWidth) {
        self.id = id
        self.width = width
    }
}

extension ImageID {
    
    var resolvedUrl: URL? {
        UrlResolver.resolvedUrl(.image(id: id, width: width))
    }
    
}
