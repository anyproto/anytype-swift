//
//  BlocksViews+NewSupplement+Flattener+Other.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 24.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.NewSupplement.Other
fileprivate typealias ViewModels = BlocksViews.New.Other

extension BlocksViews.NewSupplement {
    enum Other {}
}

extension Namespace {
    class Flattener: BlocksViews.NewSupplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: Information) -> [BlockViewBuilderProtocol] {
            switch information.content {
            case .divider: return [ViewModels.Divider.ViewModel.init(model)] + self.processChildrenToList(model)
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
