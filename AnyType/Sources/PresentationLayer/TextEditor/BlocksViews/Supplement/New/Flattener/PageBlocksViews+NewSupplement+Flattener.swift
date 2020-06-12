//
//  PageBlocksViews+Supplement+Flattener.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlocksViews.NewSupplement {
    enum Page {}
}

extension BlocksViews.NewSupplement.Page {
    /// Actually, we could place details in one list with other blocks.
    /// But for now we place them in a header view.
    /// So, this flattener is empty.
    /// 
    class Flattener: BlocksViews.NewSupplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: Information) -> [BlockViewBuilderProtocol] {
            switch (model.blockModel.kind, information.content) {
            case (.meta, .smartblock): return [] //self.convertInformation(model, model.information)
            case (.block, .smartblock): return [] //self.convertInformation(model, model.information)
            //case let .link(value) where value.style == .page: return [ToolsBlocksViews.PageLink.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            default: return []
            }            
        }
        
        // MARK: Subclassing
        override func convert(model: Model) -> [BlockViewBuilderProtocol] {
            let blockModel = model.blockModel
            switch (blockModel.kind, blockModel.information.content) {
            case (.meta, .smartblock): return self.convertInformation(model, blockModel.information)
            case (.block, .smartblock): return self.convertInformation(model, blockModel.information)
            default: return []
            }
        }
    }
}
