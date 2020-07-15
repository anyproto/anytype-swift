//
//  FileBlocksViews+Supplement+Flattener.swift
//  AnyType
//
//  Created by Valentie on 10.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension FileBlocksViews.Supplement {
    class Flattener: BlocksViews.Supplement.BaseFlattener {
        
        // MARK: Convert Blocks
        private func convertInformation(_ model: Model, _ information: MiddlewareBlockInformationModel, _ type: BlockType.File) -> [BlockViewBuilderProtocol] {
            switch type.contentType {
            case .image: return  [FileBlocksViews.Image.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            default: return []
            }
        }
        
        // MARK: Subclassing
        override func convert(model: Model) -> [BlockViewBuilderProtocol] {
            switch model.kind {
            case .meta: return []
            case .block:
                switch model.information.content {
                case let .file(value): return self.convertInformation(model, model.information, value)

                default: return []
                }
            }
        }
    }
}
