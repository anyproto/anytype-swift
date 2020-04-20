//
//  FileBlocksViews+UserActions.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 16.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension FileBlocksViews {
    /// It is specific `UserAction` for FileBlocks.
    /// It contains specific cases for each subtype of specific BlocksViews.
    /// In our case we have entries referred to `.image`, `.video` and `.file` blocks.
    ///
    enum UserAction {
        case image(ImageAction)
    }
}

extension FileBlocksViews.UserAction {
    typealias Model = BlockModels.Block.RealBlock
    enum ImageAction {
        case shouldShowImagePicker(Model)
    }
}
