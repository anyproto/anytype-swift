//
//  BlocksViews+Supplement.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 24.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlocksViews.Supplement {
    class BaseFlattener {
        typealias Model = BlockModels.Block.RealBlock
        
        func matchModelType(_ model: Model) -> BaseFlattener? {
            nil
        }
        func convertModel(_ model: Model) -> [BlockViewBuilderProtocol] {
            self.matchModelType(model)?.convertModel(model) ?? []
        }
        func toList(_ model: Model) -> [BlockViewBuilderProtocol] {
            switch model.kind {
            case .meta where !BlockModels.Utilities.Inspector.isNumberedList(model): return model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            default: return self.convertModel(model)
            }
        }
    }
}

extension BlocksViews.Supplement {
    class BlocksFlattener: BaseFlattener {
        var textFlattener = TextBlocksViews.Supplement.Flattener()
        
        override func matchModelType(_ model: Model) -> BaseFlattener? {
            switch model.kind {
            case .meta where BlockModels.Utilities.Inspector.isNumberedList(model): return self.textFlattener // text
            case .meta: return nil
            case .block:
                switch MetaBlockType.from(model.information) {
                case .text: return self.textFlattener
                case .image: return nil
                case .video: return nil
                }
            }
        }
    }
}

extension TextBlocksViews.Supplement {
    class Flattener: BlocksViews.Supplement.BaseFlattener {
        private func convertInformation(_ model: Model, _ information: MiddlewareBlockInformationModel, _ type: BlockType.Text) -> [BlockViewBuilderProtocol] {
            switch type.contentType {
            case .text: return [TextBlocksViews.Text.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            case .header: return [TextBlocksViews.Header.BlockViewModel.init(model)] + model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
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
        private func convertNumberedList(_ model: Model) -> [BlockViewBuilderProtocol] {
            var result: [BlockViewBuilderProtocol] = []
            for (index, entry) in model.blocks.enumerated() {
                result.append(TextBlocksViews.Numbered.BlockViewModel.init(entry as! Model).update(style: .number(index.advanced(by: 1))))
                result.append(contentsOf: entry.blocks.compactMap({$0 as? Model}).flatMap(self.toList))
            }
            return result
        }
        override func convertModel(_ model: Model) -> [BlockViewBuilderProtocol] {
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

// MARK: MetaBlockType
// Brief: BlockType -> String
// Overview:
// Maps BlockType ( .text, .image, .video ) to String.
// This type automatically adopts Hashable and Equatable protocols and can be used as key in dictionaries.
private enum MetaBlockType: String {
    case text, image, video
    
    static func from(_ block: MiddlewareBlockInformationModel) -> Self {
        switch block.content {
        case .text(_): return .text
        case .image(_): return .image
        case .video: return .video
            // TODO:
        // add others
        default: return .text
        }
    }
}


// TODO: Remove when we will be ready.
extension BlocksViews.Supplement {
    
    class BaseBlocksSeriazlier {
        typealias Model = BlockModels.Block.RealBlock
        // TODO: Move it to each block where block should conform equitability
        private static func sameBlock(lhs: Model, rhs: Model) -> Bool {
            switch (lhs.information.content, rhs.information.content) {
            case let (.text(left), .text(right)): return left.contentType == right.contentType
            case let (.image(left), .image(right)): return left.contentType == right.contentType
            case (.video, .video): return true
            default: return false
            }
        }
        
        // TODO: Subclass
        open func sequenceResolver(block: Model, blocks: [Model]) -> [BlockViewBuilderProtocol] {
            return []
        }
        
        private func sequencesResolver(blocks: [Model]) -> [BlockViewBuilderProtocol] {
            guard let first = blocks.first else { return [] }
            return self.sequenceResolver(block: first, blocks: blocks)
        }
        
        public func resolver(blocks: [Model]) -> [BlockViewBuilderProtocol] {
            DataStructures.GroupBy.group(blocks, by: Self.sameBlock).flatMap(self.sequencesResolver(blocks:))
        }
    }
    
    // MARK: BlocksSerializer
    // It dispatches blocks types to appropriate serializers.
    class BlocksSerializer: BaseBlocksSeriazlier {
        static var `default`: BlocksSerializer = {
            let value = BlocksSerializer()
            value.serializers = value.defaultSerializers()
            return value
        }()
        private var serializers: [MetaBlockType : BaseBlocksSeriazlier] = [:]
        
        private func defaultSerializers() -> [MetaBlockType : BaseBlocksSeriazlier] {
            [
                .text: TextBlocksViews.Supplement.Matcher(),
                .image: ImageBlocksViews.Supplement.Matcher(),
                .video: TextBlocksViews.Supplement.Matcher()
            ]
        }
        override private init() {}
        
        override func sequenceResolver(block: Model, blocks: [Model]) -> [BlockViewBuilderProtocol] {
            return self.serializers[MetaBlockType.from(block.information)]?.sequenceResolver(block: block, blocks: blocks) ?? []
        }
    }
}
