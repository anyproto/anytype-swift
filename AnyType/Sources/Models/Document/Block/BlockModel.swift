//
//  BlockModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

enum Content {
    case text(TextContent)
    case header
    case quote
    case todo
    case bulleted
    case numbered
    case toggle
    case callout
}

struct Block: Identifiable {
    var id: String
    var parentId: String
    var type: Content
}
