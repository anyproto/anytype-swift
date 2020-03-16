//
//  BlockModel+Parser.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let blockModelsParser = "models.BlockModels.Parser"
}

// MARK: Parser
extension BlockModels {
    class Parser {}
}

extension BlockModels.Parser {
    typealias Information = BlockModels.Block.Information
    typealias Model = BlockModels.Block.RealBlock
    
    // Also add methods that convert intrenal models to our models.
    // We should provide operations in Updater which rely on block.id.
    // This allows us to build a tree and later insert subtree in our tree.
    func parse(blocks: [Anytype_Model_Block]) -> [MiddlewareBlockInformationModel] {
        // parse into middleware block information model.
        blocks.compactMap(self.convert(block:))
    }
    
    func convert(block: Anytype_Model_Block) -> MiddlewareBlockInformationModel? {
        guard let content = block.content, let converter = Converters.convert(from: content) else { return nil }
        guard let blockType = converter.blockType(content) else { return nil }
        var information = Information.init(id: block.id, content: blockType)
        
        // TODO: Add fields and restrictions.
        // Add parsers for them and model.
        let logger = Logging.createLogger(category: .todo(.improve("")))
        os_log(.debug, log: logger, "Add fields and restrictions into our model.")
        return information.update(childrenIds: block.childrenIds)
    }
}

// MARK: Converters
extension BlockModels.Parser {
    enum Converters {
        static func convert(from middleware: Anytype_Model_Block.OneOf_Content?) -> BaseContentConverter? {
            guard let middleware = middleware else { return nil }
            switch middleware {
            case .page: return ContentPage()
            case .text: return ContentText()
            default: return nil
            }
        }
        class BaseContentConverter {
            open func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? { nil }
            open func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? { nil }
        }
    }
}

// MARK: ContentPage
extension BlockModels.Parser.Converters {
    class ContentPage: BaseContentConverter {
        func contentType(_ from: Anytype_Model_Block.Content.Page.Style) -> BlockType.Page.Style? {
            switch from {
            case .empty: return .empty
            case .task: return .task
            case .set: return .set
            case .breadcrumbs: return nil
            default: return nil
            }
        }
        func style(_ from: BlockType.Page.Style) -> Anytype_Model_Block.Content.Page.Style? {
            switch from {
            case .empty: return .empty
            case .task: return .task
            case .set: return .set
            }
        }
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
            case let .page(value): return self.contentType(value.style).flatMap({BlockType.page(.init(style: $0))})
            default: return nil
            }
        }
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .page(value): return self.style(value.style).flatMap({.page(.init(style: $0))})
            default: return nil
            }
        }
    }
}

// MARK: ContentText
extension BlockModels.Parser.Converters {
    class ContentText: BaseContentConverter {
        func contentType(_ from: Anytype_Model_Block.Content.Text.Style) -> BlockType.Text.ContentType? {
            func result(_ from: Anytype_Model_Block.Content.Text.Style) -> BlockType.Text.ContentType? {
                switch from {
                case .paragraph: return .text
                case .header1: return .header
                case .header2: return nil
                case .header3: return nil
                case .header4: return nil
                case .quote: return .quote
                case .code: return nil
                case .title: return nil
                case .checkbox: return .todo
                case .marked: return .bulleted
                case .numbered: return .numbered
                case .toggle: return .toggle
                default: return nil
                }
            }
            
            func descriptive(_ from: Anytype_Model_Block.Content.Text.Style) -> BlockType.Text.ContentType? {
                let value = result(from)
                if value == nil {
                    let logger = Logging.createLogger(category: .todo(.improve("")))
                    os_log(.debug, log: logger, "Do not forget to add these entries in parser: %@", String(describing: from))
                }
                return value
            }
            
            return descriptive(from)
        }
        func style(_ from: BlockType.Text.ContentType) -> Anytype_Model_Block.Content.Text.Style? {
            switch from {
            case .text: return .paragraph
            case .header: return .header1
            case .quote: return .quote
            case .todo: return .checkbox
            case .bulleted: return .marked
            case .numbered: return .numbered
            case .toggle: return .toggle
            default: return nil
            }
        }
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
            case let .text(value): return self.contentType(value.style).flatMap({BlockType.text(.init(text: value.text, contentType: $0))})
            default: return nil
            }
        }
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .text(value): return self.style(value.contentType).flatMap({
                    .text(.init(text: value.text, style: $0, marks: .init(), checked: false, color: "", backgroundColor: ""))
                })
            default: return nil
            }
        }
    }
}
