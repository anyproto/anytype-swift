//
//  ToolsBlocksViews+Supplement+Flattener.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlocksViews.NewSupplement {
    enum Tools {}
}

extension BlocksViews.NewSupplement.Tools {
    class Flattener: BlocksViews.NewSupplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: Information) -> [BlockViewBuilderProtocol] {
            switch information.content {
            case let .link(value) where value.style == .page: return [BlocksViews.New.Tools.PageLink.ViewModel.init(model)] + model.childrenIds().compactMap({model.findChild(by: $0)}).flatMap(self.toList)
            default: return []
            }
        }
        
        // MARK: Subclassing
        override func convert(model: Model) -> [BlockViewBuilderProtocol] {
            let blockModel = model.blockModel
            switch blockModel.kind {
            case .meta: return []
            case .block: return self.convertInformation(model, blockModel.information)
            }
        }
    }
}
