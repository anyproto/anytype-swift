//
//  ToolsBlocksViews+Supplement+Flattener.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension ToolsBlocksViews.Supplement {
    class Flattener: BlocksViews.Supplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: MiddlewareBlockInformationModel) -> [BlockViewBuilderProtocol] {
            switch information.content {
            case let .link(value) where value.style == .page: return [ToolsBlocksViews.PageLink.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            default: return []
            }
        }
        
        // MARK: Subclassing
        override func convert(model: Model) -> [BlockViewBuilderProtocol] {
            switch model.kind {
            case .meta: return []
            case .block: return self.convertInformation(model, model.information)
            }
        }
    }
}
