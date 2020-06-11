//
//  BlocksModels.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 03.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

enum BlocksModels {
    enum Block {}
}

extension BlocksModels {
    enum Aliases {
        typealias BlockId = String
        typealias BlockContent = BlocksModels.Block.Content.ContentType
        typealias ChildrenIds = [BlockId]
        typealias BackgroundColor = String
        typealias Alignment = BlocksModels.Block.Information.Alignment
        typealias PageDetails = BlocksModels.Block.Information.PageDetails
        
        typealias BlockKind = BlocksModels.Block.Kind
    }
}
