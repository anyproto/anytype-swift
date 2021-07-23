//
//  BlocksViews+Supplement+Flattener+Other.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 24.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.Supplement
fileprivate typealias FileNamespace = Namespace.Other
fileprivate typealias ViewModels = BlocksViews.New.Other

extension Namespace {
    enum Other {}
}

extension FileNamespace {
    class Flattener: BlocksViews.Supplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: Information) -> [ResultViewModel] {
            switch information.content {
            case .divider: return [ViewModels.Divider.ViewModel.init(model)] + self.processChildrenToList(model)
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
