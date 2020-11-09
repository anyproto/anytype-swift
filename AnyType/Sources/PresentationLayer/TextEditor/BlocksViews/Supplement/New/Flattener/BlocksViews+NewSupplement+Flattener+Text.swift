//
//  BlocksViews+NewSupplement+Flattener+Text.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.NewSupplement
fileprivate typealias ViewModels = BlocksViews.New.Text

extension Namespace {
    enum Text {}
}

extension Namespace.Text {
    class Flattener: BlocksViews.NewSupplement.BaseFlattener {
        
        // MARK: Convert Blocks        
        private func convertInformation(_ model: Model, _ information: Information) -> [BlockViewBuilderProtocol] {
            switch information.content {
            case let .text(value):
                switch value.contentType {
                case .text: return [ViewModels.Text.ViewModel.init(model)]
                case .header: return [ViewModels.Header.ViewModel.init(model).update(style: .heading1)]
                case .header2: return [ViewModels.Header.ViewModel.init(model).update(style: .heading2)]
                case .header3: return [ViewModels.Header.ViewModel.init(model).update(style: .heading3)]
                case .header4: return [ViewModels.Header.ViewModel.init(model).update(style: .heading4)]
                case .quote: return [ViewModels.Quote.ViewModel.init(model)]
                case .checkbox: return [ViewModels.Checkbox.ViewModel.init(model)]
                case .bulleted: return [ViewModels.Bulleted.ViewModel.init(model)]
                case .numbered: return [ViewModels.Numbered.ViewModel.init(model)]
                default: return []
                }
            default: return []
            }
        }
        
        private func convertToggledList(_ model: Model, _ information: Information) -> [BlockViewBuilderProtocol] {
            guard case let .text(value) = information.content, value.contentType == .toggle else { return [] }
            let viewModel = ViewModels.Toggle.ViewModel.init(model)
            if model.isToggled {
                return [viewModel] + self.processChildrenToList(model)
            }
            else {
                return [viewModel]
            }
        }
                
        // MARK: Subclassing
        override func convert(model: Model) -> [BlockViewBuilderProtocol] {
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
  
        override func convert(child: BlocksViews.NewSupplement.BaseFlattener.Model, children: [BlocksViews.NewSupplement.BaseFlattener.Model]) -> [BlockViewBuilderProtocol] {            
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
