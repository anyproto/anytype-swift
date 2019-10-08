//
//  BlockModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

enum BlockType {
    case text(Text)
    case image
    case video
}

extension BlockType {
    
    struct Text {
        enum ContentType {
            case text
            case header
            case quote
            case todo
            case bulleted
            case numbered
            case toggle
            case callout
        }
        
        var text: String
        var contentType: ContentType
    }
}

extension BlockType {
    
    struct Video {
    }
}

struct Block: Identifiable {
    var id: String
    var parentId: String
    var type: BlockType
}
