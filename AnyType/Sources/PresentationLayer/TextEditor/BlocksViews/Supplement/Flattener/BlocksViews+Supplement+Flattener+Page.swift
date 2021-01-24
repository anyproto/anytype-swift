//
//  BlocksViews+Supplement+Flattener+Page.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.Supplement
fileprivate typealias FileNamespace = Namespace.Page
fileprivate typealias ViewModels = BlocksViews.New.Page

extension Namespace {
    enum Page {}
}

extension FileNamespace {
    /// Actually, we could place details in one list with other blocks.
    /// But for now we place them in a header view.
    /// So, this flattener is empty.
    /// 
    class Flattener: BlocksViews.Supplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: Information) -> [ResultViewModel] {
            switch (model.blockModel.kind, information.content) {
            case (.meta, .smartblock): return [] //self.convertInformation(model, model.information)
            case (.block, .smartblock): return [] //self.convertInformation(model, model.information)
            //case let .link(value) where value.style == .page: return [ToolsBlocksViews.PageLink.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            default: return []
            }            
        }
        
        // MARK: Subclassing
        override func convert(model: Model) -> [ResultViewModel] {
            let blockModel = model.blockModel
            switch (blockModel.kind, blockModel.information.content) {
            case (.meta, .smartblock): return self.convertInformation(model, blockModel.information)
            case (.block, .smartblock): return self.convertInformation(model, blockModel.information)
            default: return []
            }
        }
    }
}
