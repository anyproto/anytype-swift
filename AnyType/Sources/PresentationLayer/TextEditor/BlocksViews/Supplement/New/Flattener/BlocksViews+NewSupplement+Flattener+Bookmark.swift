//
//  BlocksViews+NewSupplement+Flattener+Bookmark.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 28.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.NewSupplement.Bookmark
fileprivate typealias ViewModels = BlocksViews.New.Bookmark

extension BlocksViews.NewSupplement {
    enum Bookmark {}
}

extension Namespace {
    class Flattener: BlocksViews.NewSupplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: Information) -> [BlockViewBuilderProtocol] {
            switch information.content {
            case .bookmark: return [ViewModels.Bookmark.ViewModel.init(model)] + self.processChildrenToList(model)
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
