//
//  BlocksViews+Supplement+Flattener+Text.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.Supplement
fileprivate typealias FileNamespace = Namespace.Text
fileprivate typealias ViewModels = BlocksViews.New.Text

extension Namespace {
    enum Text {}
}

extension FileNamespace {
    class Flattener: BlocksViews.Supplement.BaseFlattener {
        
        // MARK: Convert Blocks        
        private func convertInformation(_ model: Model, _ information: Information) -> [ResultViewModel] {
            switch information.content {
            case let .text(value):
                switch value.contentType {
                case .text,
                     .quote,
                     .checkbox,
                     .bulleted,
                     .numbered,
                     .toggle,
                     .header,
                     .header2,
                     .header3,
                     .header4:
                    return [ViewModels.Base.ViewModel(model)]
                case .callout: return []
                }
            default: return []
            }
        }
        
        private func convertToggledList(_ model: Model, _ information: Information) -> [ResultViewModel] {
            guard case let .text(value) = information.content, value.contentType == .toggle else { return [] }
            let viewModel = ViewModels.Base.ViewModel(model)
            if model.isToggled {
                return [viewModel] + self.processChildrenToList(model)
            }
            else {
                return [viewModel]
            }
        }
                
        // MARK: Subclassing
        override func convert(model: Model) -> [ResultViewModel] {
            let blockModel = model.blockModel
            
            switch blockModel.kind {
            case .meta: return []
            case .block:
                switch blockModel.information.content {
                case let .text(value) where value.contentType == .toggle: return self.convertToggledList(model, blockModel.information)
//                case let .text(value) where value.contentType == .numbered: return []
                case let .text(value) where value.contentType == .text: return self.convertInformation(model, blockModel.information) + self.processChildrenToList(model)
                case .text: return self.unknownCaseRouter?.convert(model: model) ?? []
                default: return []
                }
            }
        }
        
        override func convert(child: Model, children: [Model]) -> [ResultViewModel] {
            if !children.isEmpty, case let .text(value) = child.blockModel.information.content, value.contentType == .numbered {
                for (index, entry) in children.enumerated() {
                    // We should create view model or even not create and just update value of model.
                    // and then, we should process them as usual.
                    ViewModels.Numbered.ViewModel.init(entry).updateInternal(style: .number(index.advanced(by: 1)))
                }
            }
            return super.convert(child: child, children: children)
        }
    }
}
