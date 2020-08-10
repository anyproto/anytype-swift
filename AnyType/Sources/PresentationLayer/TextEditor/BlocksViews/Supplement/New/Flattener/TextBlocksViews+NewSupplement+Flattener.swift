//
//  TextBlocksViews+Supplement+Flattener.swift
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
        
        // MARK: Convert Numbered List
        private func convertNumberedList(_ model: Model) -> [BlockViewBuilderProtocol] {

            //            var result: [BlockViewBuilderProtocol] = []
//            for (index, entry) in model.blocks.enumerated() {
//                result.append(TextBlocksViews.Numbered.BlockViewModel.init(entry as! Model).update(style: .number(index.advanced(by: 1))))
//                result.append(contentsOf: entry.blocks.compactMap({$0 as? Model}).flatMap(self.toList))
//            }
//            return result
            
            return []
        }
        
        // MARK: Subclassing
        override func convert(model: Model) -> [BlockViewBuilderProtocol] {
            let blockModel = model.blockModel
            
            switch blockModel.kind {
            case .meta: return []
            case .block:
                switch blockModel.information.content {
                case let .text(value) where value.contentType == .toggle: return self.convertToggledList(model, blockModel.information)
                case let .text(value) where value.contentType == .numbered: return []
                case .text: return self.convertInformation(model, blockModel.information) + self.processChildrenToList(model)
                default: return []
                }
            }
        }
    }
}
