//
//  DrawableBlocksViews.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

enum FileBlocksViews {
    enum Image {} // -> Image.ContentType.image
}

extension FileBlocksViews {
    enum Base {}
}

extension FileBlocksViews.Base {
    class BlockViewModel: BlocksViews.Base.ViewModel {
        typealias State = BlockType.File.State
              
        @Published var state: State? { willSet { self.objectWillChange.send() } }
    }
}

extension FileBlocksViews {
    enum Supplement {}
}

extension FileBlocksViews.Supplement {
    class Matcher: BlocksViews.Supplement.BaseBlocksSeriazlier {
        override func sequenceResolver(block: Model, blocks: [Model]) -> [BlockViewBuilderProtocol] {
            switch block.information.content {
            case let .file(file):
                switch file.contentType {
                case .image: return blocks.map(FileBlocksViews.Image.BlockViewModel.init)
                case .video:
                    // Add later
                    return []
                }
            default: return []
            }
        }
    }
}
