//
//  BlocksViews+Supplement+Flattener+Tools.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.Supplement
fileprivate typealias FileNamespace = Namespace.Tools
fileprivate typealias ViewModels = BlocksViews.New.Tools

extension Namespace {
    enum Tools {}
}

extension FileNamespace {
    class Flattener: BlocksViews.Supplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: Information) -> [ResultViewModel] {
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
        override func convert(model: Model) -> [ResultViewModel] {
            let blockModel = model.blockModel
            switch blockModel.kind {
            case .meta: return []
            case .block: return self.convertInformation(model, blockModel.information)
            }
        }
    }
}
