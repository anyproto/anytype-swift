//
//  BlocksViews.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
enum BlocksViews {
    enum Supplement {}
}

// MARK: MetaBlockType
// Brief: BlockType -> String
// Overview:
// Maps BlockType ( .text, .image, .video ) to String.
// This type automatically adopts Hashable and Equatable protocols and can be used as key in dictionaries.
private enum MetaBlockType: String {
    case text, image, video
    static func from(_ block: Block) -> Self {
        switch block.type {
        case .text(_): return .text
        case .image(_): return .image
        case .video: return .video
        }
    }
}

extension BlocksViews.Supplement {
    class BaseBlocksSeriazlier {
        // Move it somewhere later.        
        private static func sameBlock(lhs: Block, rhs: Block) -> Bool {
            switch (lhs.type, rhs.type) {
            case let (.text(left), .text(right)): return left.contentType == right.contentType
            case let (.image(left), .image(right)): return left.contentType == right.contentType
            case (.video, .video): return true
            default: return false
            }
        }
        
        // TODO: Subclass
        open func sequenceResolver(block: Block, blocks: [Block]) -> [BlockViewRowBuilderProtocol] {
            return []
        }

        private func sequencesResolver(blocks: [Block]) -> [BlockViewRowBuilderProtocol] {
            guard let first = blocks.first else { return [] }
            return self.sequenceResolver(block: first, blocks: blocks)
        }
        
        public func resolver(blocks: [Block]) -> [BlockViewRowBuilderProtocol] {
            if blocks.isEmpty {
                return []
            }
            
            // 1. first step - group together views which have "same" blocks. ( types and content types are the same ).
            let remains = blocks.dropFirst()
            let prefix = blocks.prefix(1)
            let firstElements = Array(prefix)
            
            let grouped = remains.reduce([firstElements]) { (result, block) in
                var result = result
                if let lastGroup = result.last, let firstObject = lastGroup.first, Self.sameBlock(lhs: firstObject, rhs: block) {
                    result = result.dropLast() + [(lastGroup + [block])]
                }
                else {
                    result.append([block])
                }
                return result
            }
            
            // 2. Next, we have to choose which group has which ViewModel
            let result = grouped.flatMap { (blocks) in
                self.sequencesResolver(blocks: blocks)
            }
            return result
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
            return [
                .text: TextBlocksViews.Supplement.Matcher(),
                .image: ImageBlocksViews.Supplement.Matcher(),
                .video: TextBlocksViews.Supplement.Matcher()
            ]
        }
        override private init() {}
        
        override func sequenceResolver(block: Block, blocks: [Block]) -> [BlockViewRowBuilderProtocol] {
            return self.serializers[MetaBlockType.from(block)]?.sequenceResolver(block: block, blocks: blocks) ?? []
        }
    }
}
