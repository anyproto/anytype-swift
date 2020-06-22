//
//  FileBlocksViews+Supplement+Flattener.swift
//  AnyType
//
//  Created by Valentie on 10.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlocksViews.NewSupplement {
    enum File {}
}

extension BlocksViews.NewSupplement.File {
    class Flattener: BlocksViews.NewSupplement.BaseFlattener {
        
        // MARK: Convert Blocks
        private func convertInformation(_ model: Model, _ information: Information) -> [BlockViewBuilderProtocol] {
            switch information.content {
            case let .file(value) where value.contentType == .image: return [BlocksViews.New.File.Image.ViewModel.init(model)] + model.childrenIds().compactMap(model.findChild(by:)).flatMap(self.toList)
            default: return []
            }
        }
        
        // MARK: Subclassing
        override func convert(model: Model) -> [BlockViewBuilderProtocol] {
            let blockModel = model.blockModel
            switch blockModel.kind {
            case .meta: return []
            case .block:
                switch blockModel.information.content {
                case .file: return self.convertInformation(model, blockModel.information)
                default: return []
                }
            }
        }
    }
}
