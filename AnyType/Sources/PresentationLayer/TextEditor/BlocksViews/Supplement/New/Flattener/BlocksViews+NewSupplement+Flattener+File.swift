//
//  BlocksViews+NewSupplement+Flattener+File.swift
//  AnyType
//
//  Created by Valentie on 10.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.NewSupplement.File
fileprivate typealias ViewModels = BlocksViews.New.File

extension BlocksViews.NewSupplement {
    enum File {}
}

extension Namespace {
    class Flattener: BlocksViews.NewSupplement.BaseFlattener {
        
        // MARK: Convert Blocks
        private func convertInformation(_ model: Model, _ information: Information) -> [BlockViewBuilderProtocol] {
            switch information.content {
            case let .file(value) where value.contentType == .image: return [ViewModels.Image.ViewModel.init(model)]
            case let .file(value) where value.contentType == .file: return [ViewModels.File.ViewModel.init(model)]
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
                case .file: return self.convertInformation(model, blockModel.information) + self.processChildrenToList(model)
                default: return []
                }
            }
        }
    }
}
