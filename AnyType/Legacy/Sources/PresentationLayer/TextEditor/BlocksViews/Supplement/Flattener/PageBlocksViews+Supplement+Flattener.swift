//
//  PageBlocksViews+Supplement+Flattener.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension PageBlocksViews.Supplement {
    /// Actually, we could place details in one list with other blocks.
    /// But for now we place them in a header view.
    /// So, this flattener is empty.
    /// 
    class Flattener: BlocksViews.Supplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: MiddlewareBlockInformationModel) -> [BlockViewBuilderProtocol] {
            switch (model.kind, information.content) {            
            case (.meta, .page): return [] //self.convertInformation(model, model.information)
            case (.block, .page): return [] //self.convertInformation(model, model.information)
            //case let .link(value) where value.style == .page: return [ToolsBlocksViews.PageLink.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            default: return []
            }            
        }
        
        // MARK: Subclassing
        override func convert(model: Model) -> [BlockViewBuilderProtocol] {
            switch (model.kind, model.information.content) {
            case (.meta, .page): return self.convertInformation(model, model.information)
            case (.block, .page): return self.convertInformation(model, model.information)
            default: return []
            }
        }
    }
}
