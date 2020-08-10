//
//  ToolsBlocksViews+Supplement+Flattener.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.NewSupplement.Tools
fileprivate typealias ViewModels = BlocksViews.New.Tools

extension BlocksViews.NewSupplement {
    enum Tools {}
}

extension Namespace {
    class Flattener: BlocksViews.NewSupplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: Information) -> [BlockViewBuilderProtocol] {
            switch information.content {
            case let .link(value) where [.page, .archive].contains(value.style):
                let viewModel = ViewModels.PageLink.ViewModel.init(model)
                
                if let details = self.getContainer()?.detailsContainer.choose(by: value.targetBlockID) {
                    _ = viewModel.configured(details.didChangeInformationPublisher())
                }
                
                return [viewModel] + self.processChildrenToList(model)
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
