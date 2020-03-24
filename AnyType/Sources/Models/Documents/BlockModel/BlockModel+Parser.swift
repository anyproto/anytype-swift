//
//  BlockModel+Parser.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftProtobuf
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
    
    /// Converting Middleware model -> Our model
    ///
    /// - Parameter block: Middleware model
    func convert(block: Anytype_Model_Block) -> MiddlewareBlockInformationModel? {
        guard let content = block.content, let converter = Converters.convert(middleware: content) else { return nil }
        guard let blockType = converter.blockType(content) else { return nil }
        var information = Information.init(id: block.id, content: blockType)
        
        // TODO: Add fields and restrictions.
        // Add parsers for them and model.
        let logger = Logging.createLogger(category: .todo(.improve("")))
        os_log(.debug, log: logger, "Add fields and restrictions into our model.")
        return information.update(childrenIds: block.childrenIds)
    }
    
    
    /// Converting Our model -> Middleware model
    ///
    /// - Parameter information: Our model
    func convert(information: MiddlewareBlockInformationModel) -> Anytype_Model_Block? {
        let blockType = information.content
        guard let converter = Converters.convert(block: blockType) else { return nil }
        guard let content = converter.middleware(blockType) else { return nil }
        
        let id = information.id
        let fields: Google_Protobuf_Struct = .init()
        let restrictions: Anytype_Model_Block.Restrictions = .init()
        let childrenIds = information.childrenIds
                
        let logger = Logging.createLogger(category: .todo(.improve("")))
        os_log(.debug, log: logger, "Add fields and restrictions into our model.")
        return .init(id: id, fields: fields, restrictions: restrictions, childrenIds: childrenIds, content: content)
    }
}

// MARK: Converters
private extension BlockModels.Parser {
    /// It is a Converters Factory, actually.
    enum Converters {
        static func convert(middleware: Anytype_Model_Block.OneOf_Content?) -> BaseContentConverter? {
            guard let middleware = middleware else { return nil }
            switch middleware {
            case .page: return ContentPage()
            case .text: return ContentText()
            default: return nil
            }
        }
        static func convert(block: BlockType?) -> BaseContentConverter? {
            guard let block = block else { return nil }
            switch block {
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
private extension BlockModels.Parser.Converters {
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
private extension BlockModels.Parser.Converters {
    class ContentText: BaseContentConverter {
        func contentType(_ from: Anytype_Model_Block.Content.Text.Style) -> BlockType.Text.ContentType? {
            func result(_ from: Anytype_Model_Block.Content.Text.Style) -> BlockType.Text.ContentType? {
                switch from {
                case .paragraph: return .text
                case .header1: return .header
                case .header2: return .header2
                case .header3: return .header3
                case .header4: return .header4
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
            case .header2: return .header2
            case .header3: return .header3
            case .header4: return .header4
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
