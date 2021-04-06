//
//  BlocksModelsModule+Parser.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftProtobuf
import os
import BlocksModels
import ProtobufMessages

fileprivate typealias Namespace = BlocksModelsModule
fileprivate typealias FileNamespace = BlocksModelsModule.Parser

private extension Logging.Categories {
    static let blockModelsParser: Self = "BlocksModels.Module.Parser"
}

// MARK: - Parser
extension Namespace {
    class Parser {
        typealias Information = Block.Information.InformationModel
        typealias Model = BlockModelProtocol
        typealias OurContent = TopLevel.BlockContent
        typealias Builder = TopLevel.Builder
    }
}

extension Namespace.Parser {
    struct PageEvent {
        var rootId: String
        var blocks: [Block.Information.InformationModel] = []
        var details: [DetailsInformationModelProtocol] = []
        static func empty() -> Self { .init(rootId: "") }
    }
}

// MARK: - Parser / Parse
extension Namespace.Parser {
    /// Also add methods that convert intrenal models to our models.
    /// We should provide operations in Updater which rely on block.id.
    /// This allows us to build a tree and later insert subtree in our tree.
    ///
    func parse(blocks: [Anytype_Model_Block]) -> [Information] {
        // parse into middleware block information model.
        blocks.compactMap(self.convert(block:))
    }
    
    /// New cool parsing that takes into account details and smartblock type.
    ///
    /// Discussion.
    ///
    /// Our parsing happens, of course, from some events.
    /// Most of our events will send common data as `contextID`.
    /// Also, blocks can't be delivered to us without some `context` of `Outer block`.
    /// This `Outer block` is named as `Smartblock` in middleware model.
    ///
    /// * This block could contain `details`. It is a structure ( or a dictionary ) with predefined fields.
    /// * This block also has type `smartblockType`. It is a `.case` from enumeration.
    ///
    func parse(blocks: [Anytype_Model_Block], details: [Anytype_Event.Block.Set.Details], smartblockType: Anytype_SmartBlockType) -> PageEvent {
        
        let root = blocks.first(where: {
            switch $0.content {
            case .smartblock: return true
            default: return false
            }
        })
                
        let parsedBlocks = self.parse(blocks: blocks)
        
        let parsedDetails = details.map { (value) -> DetailsInformationModelProtocol in
            let corrected = Converters.EventDetailsAndSetDetailsConverter.convert(event: value)
            let contentList = Details.Converter.asModel(details: corrected)
            var result = TopLevel.Builder.detailsBuilder.informationBuilder.build(list: contentList)
            result.parentId = value.id
            return result
        }
        
        guard let rootId = root?.id else {
            return .empty()
        }
        
        return .init(rootId: rootId, blocks: parsedBlocks, details: parsedDetails)
    }
}

// MARK: - Parser / Convert
extension Namespace.Parser {
    // MARK: - Blocks
    /// Converting Middleware model -> Our model
    ///
    /// - Parameter block: Middleware model
    func convert(block: Anytype_Model_Block) -> Information? {
        guard let content = block.content, let converter = Converters.convert(middleware: content) else { return nil }
        guard let blockType = converter.blockType(content) else { return nil }
        
        var information = Builder.blockBuilder.informationBuilder.build(id: block.id, content: blockType)

        // TODO: Add fields and restrictions.
        // Add parsers for them and model.
        let logger = Logging.createLogger(category: .todo(.improve("")))
        os_log(.debug, log: logger, "Add fields and restrictions into our model.")
        information.childrenIds = block.childrenIds
        information.backgroundColor = block.backgroundColor
        if let alignment = Common.Alignment.Converter.asModel(block.align) {
            information.alignment = alignment
        }
        return information
    }
    
    
    /// Converting Our model -> Middleware model
    ///
    /// - Parameter information: Our model
    func convert(information: Information) -> Anytype_Model_Block? {
        let blockType = information.content
        guard let converter = Converters.convert(block: blockType) else { return nil }
        guard let content = converter.middleware(blockType) else { return nil }

        let id = information.id
        let fields: Google_Protobuf_Struct = .init()
        let restrictions: Anytype_Model_Block.Restrictions = .init()
        let childrenIds = information.childrenIds
        let backgroundColor = information.backgroundColor
        
        var alignment: Anytype_Model_Block.Align = .left
        if let value = Common.Alignment.Converter.asMiddleware(information.alignment) {
            alignment = value
        }

        let logger = Logging.createLogger(category: .todo(.improve("")))
        os_log(.debug, log: logger, "Add fields and restrictions into our model.")
        return .init(id: id, fields: fields, restrictions: restrictions, childrenIds: childrenIds, backgroundColor: backgroundColor, align: alignment, content: content)
    }
    
    // MARK: - Content
    /// Converting Middleware Content -> Our Content
    /// - Parameter middlewareContent: Middleware Content
    /// - Returns: Our content
    func convert(middlewareContent: Anytype_Model_Block.OneOf_Content) -> OurContent? {
        Converters.convert(middleware: middlewareContent)?.blockType(middlewareContent)
    }
    
    /// Converting Our Content -> Middleware Content
    /// - Parameter content: Our content
    /// - Returns: Middleware Content
    func convert(content: OurContent) -> Anytype_Model_Block.OneOf_Content? {
        Converters.convert(block: content)?.middleware(content)
    }
}

// MARK: - Converters
// MARK: - Public
extension FileNamespace {
    enum PublicConverters {
        enum EventsDetails {
            static func convert(event: Anytype_Event.Block.Set.Details) -> [Anytype_Rpc.Block.Set.Details.Detail] {
                Converters.EventDetailsAndSetDetailsConverter.convert(event: event)
            }
        }
    }
}

extension FileNamespace {
    enum Converters {
        typealias BlockType = OurContent
        class BaseContentConverter {
            open func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? { nil }
            open func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? { nil }
        }
    }
}

// MARK: - Converters / Common
private extension FileNamespace.Converters {
    /// It is a Converters Factory, actually.
    private static var contentObjectAsEmptyPage: ContentObjectAsEmptyPage = .init()
    private static var contentLink: ContentLink = .init()
    private static var contentText: ContentText = .init()
    private static var contentFile: ContentFile = .init()
    private static var contentBookmark: ContentBookmark = .init()
    private static var contentDivider: ContentDivider = .init()
    private static var contentLayout: ContentLayout = .init()
    
    static func convert(middleware: Anytype_Model_Block.OneOf_Content?) -> BaseContentConverter? {
        switch middleware {
        case .smartblock: return self.contentObjectAsEmptyPage
        case .link: return self.contentLink
        case .text: return self.contentText
        case .file: return self.contentFile
        case .bookmark: return self.contentBookmark
        case .div: return self.contentDivider
        case .layout: return self.contentLayout
        default: return nil
        }
    }
    static func convert(block: BlockType?) -> BaseContentConverter? {
        switch block {
        case .smartblock: return self.contentObjectAsEmptyPage
        case .link: return self.contentLink
        case .text: return self.contentText
        case .file: return self.contentFile
        case .bookmark: return self.contentBookmark
        case .divider: return self.contentDivider
        case .layout: return self.contentLayout
        default: return nil
        }
    }
}
