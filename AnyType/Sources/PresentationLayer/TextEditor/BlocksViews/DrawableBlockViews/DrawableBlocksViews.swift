//
//  DrawableBlocksViews.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

enum ImageBlocksViews {
    enum Image {} // -> Image.ContentType.image
    enum PageIcon {} // -> Image.ContentType.pageIcon
}

extension ImageBlocksViews {
    enum Base {}
}

extension ImageBlocksViews.Base {
    class BlockViewModel: BlocksViews.Base.ViewModel {
        @Environment(\.developerOptions) var developerOptions
        private weak var delegate: TextBlocksViewsUserInteractionProtocol?
    }
}

extension ImageBlocksViews {
    enum Supplement {}
}

extension ImageBlocksViews.Supplement {
    class Matcher: BlocksViews.Supplement.BaseBlocksSeriazlier {
        override func sequenceResolver(block: Model, blocks: [Model]) -> [BlockViewBuilderProtocol] {
            switch block.information.content {
            case let .image(text):
                switch text.contentType {
                case .image: return blocks.map(ImageBlocksViews.Image.BlockViewModel.init)
                case .pageIcon: return blocks.map(ImageBlocksViews.PageIcon.BlockViewModel.init)
                }
            default: return []
            }
        }
    }
}
