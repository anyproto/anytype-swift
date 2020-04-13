//
//  BlocksViews+Supplement.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 24.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlocksViews.Supplement {
    /// Generic interface for classes that provides following transform:
    /// (TreeModel) -> Array<ViewModel>
    class BaseFlattener {
        typealias Model = BlockModels.Block.RealBlock
        
        /// Convert tree model to list of ViewModels.
        /// NOTE: Do not override this method in subclasses.
        /// Subclass: NO.
        ///
        /// - Parameter model: Tree model that we want to convert.
        /// - Returns: List of ViewModels.
        ///
        public func toList(_ model: Model) -> [BlockViewBuilderProtocol] {
            switch model.kind {
            case .meta where !BlockModels.Utilities.Inspector.isNumberedList(model): return model.blocks.compactMap({$0 as? Model}).flatMap(self.toList)
            default: return self.convert(model: model)
            }
        }
        
        /// Find correct flattener for current model.
        /// We have different types of models ( blocks ), so, their needs are served by different Flatteners.
        /// NOTE: Override in Compound subclasses where you want to split functionality across subflatteners.
        /// Subclass: Possible for Compound Flatteners.
        ///
        /// - Parameter model: Model for which we would like to find a match.
        /// - Returns: Flattener that is matched this model and could flatten it.
        ///
        func match(_ model: Model) -> BaseFlattener? {
            nil
        }
        
        /// Convert tree model to a list of ViewModels.
        /// NOTE: It is the first method that you need to override.
        /// Subclass: YES.
        ///
        /// - Parameter model: Model that we would like to flatten.
        /// - Returns: List of Builders ( actually, view models ) that describes input model in terms of list.
        ///
        func convert(model: Model) -> [BlockViewBuilderProtocol] {
            self.match(model)?.convert(model: model) ?? []
        }

    }
}

// MARK: BlocksFlattener
extension BlocksViews.Supplement {
    /// Blocks flattener is compound flattener.
    /// It chooses correct flattener based on model type.
    class BlocksFlattener: BaseFlattener {
        var textFlattener = TextBlocksViews.Supplement.Flattener()
        
        override func match(_ model: Model) -> BaseFlattener? {
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
