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
        /// TODO: Remove PageDetails from Information.
        /// It doesn't fit well anymore.
        typealias PageDetails = BlocksModels.Block.Information.PageDetails // Actually, deprecated. We should rewrite Details parsing.
        typealias BlockKind = BlocksModels.Block.Kind
        typealias Information = BlocksModels.Block.Information
        typealias FocusPosition = BlocksModels.Block.Focus.Position
        typealias Details = BlocksModels.Block // Namespace to Details, DetailsModel and Details Container.
        /// Add distinct namespace to details?
        /// This will require sometime, but it worth (?)
    }
}
