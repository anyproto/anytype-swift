//
//  TextBlocksViews+Supplement+Flattener.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension TextBlocksViews.Supplement {
    class Flattener: BlocksViews.Supplement.BaseFlattener {
        
        // MARK: Convert Blocks
        private func convertInformation(_ model: Model, _ information: MiddlewareBlockInformationModel, _ type: BlockType.Text) -> [BlockViewBuilderProtocol] {
            switch type.contentType {
            case .text: return [TextBlocksViews.Text.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            case .header: return [TextBlocksViews.Header.BlockViewModel.init(model).update(style: .heading1)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            case .header2: return [TextBlocksViews.Header.BlockViewModel.init(model).update(style: .heading2)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            case .header3: return [TextBlocksViews.Header.BlockViewModel.init(model).update(style: .heading3)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            case .header4: return [TextBlocksViews.Header.BlockViewModel.init(model).update(style: .heading4)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            case .quote: return [TextBlocksViews.Quote.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            case .todo: return [TextBlocksViews.Checkbox.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            case .bulleted: return [TextBlocksViews.Bulleted.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            
            // NOTE: Do not delete these comments
            // Commented cases below could be used to check that all blocks are proceeded.
            
            // Also,
            // Here we could hide all blocks if we toggle block (?)
            //
            // case .numbered: return [TextBlocksViews.Numbered.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            // case .toggle: return [TextBlocksViews.Toggle.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            default: return []
            }
        }
        
        // MARK: Convert Toggle
        private func toggleStorage() -> InMemoryStoreFacade.BlockLocalStore? {
            InMemoryStoreFacade.shared.blockLocalStore
        }
        private func convertToggledList(_ model: Model, _ information: MiddlewareBlockInformationModel, _ type: BlockType.Text) -> [BlockViewBuilderProtocol] {
            guard type.contentType == .toggle else { return [] }
            let viewModel = TextBlocksViews.Toggle.BlockViewModel.init(model)
            if let value = self.toggleStorage()?[.init(blockId: model.information.id)], value.toggled {
                // NOTE: Do not delete these comments.
                // Look at commented implementation below.
                // It is necessary to keep it right now.
                // If we want to treat Toggle View Model as Compound model with several BlockViewModels as children,
                // we should set children view models.
                //
                // Implementation:
                // let blocks = model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
                // _ = viewModel.update(blocks: blocks)
                
                return [viewModel] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            }
            
            return [viewModel]
        }
        
        // MARK: Convert Numbered List
        private func convertNumberedList(_ model: Model) -> [BlockViewBuilderProtocol] {
            var result: [BlockViewBuilderProtocol] = []
            for (index, entry) in model.blocks.enumerated() {
                result.append(TextBlocksViews.Numbered.BlockViewModel.init(entry as! Model).update(style: .number(index.advanced(by: 1))))
                result.append(contentsOf: entry.blocks.compactMap({$0 as? Model}).flatMap(self.toList))
            }
            return result
        }
        
        // MARK: Subclassing
        override func convert(model: Model) -> [BlockViewBuilderProtocol] {
            switch model.kind {
            case .meta where BlockModels.Utilities.Inspector.isNumberedList(model): return self.convertNumberedList(model)
            case .meta: return []
            case .block:
                switch model.information.content {
                case let .text(value) where value.contentType == .toggle: return self.convertToggledList(model, model.information, value)
                case let .text(value): return self.convertInformation(model, model.information, value)
                default: return []
                }
            }
        }
    }
}
