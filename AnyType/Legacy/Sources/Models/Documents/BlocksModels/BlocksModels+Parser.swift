//
//  BlocksModels+Parser.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 04.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftProtobuf
import os

fileprivate typealias Namespace = BlocksModels

private extension Logging.Categories {
    static let blockModelsParser: Self = "BlocksModels.Parser"
}

// MARK: - Parser
extension Namespace {
    class Parser {
        typealias Information = BlocksModelsInformationModelProtocol
        typealias ConcreteInformation = BlocksModels.Block.Information.InformationModel
        typealias Model = BlocksModelsBlockModelProtocol
        typealias OurContent = BlocksModels.Aliases.BlockContent
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
    func parse(blocks: [Anytype_Model_Block], details: [Anytype_Event.Block.Set.Details], smartblockType: Anytype_SmartBlockType) -> [Information] {
        ///
        /// Here we have an assumption.
        ///
        /// We have only one `smartblock`.
        /// And it is stored in all blocks.
        /// This `smartblock` has type `smartblockType`.
        ///
        /// `BUT!` `.Smartblock` structure `doesn't` store `ANY` field.
        ///
        /// So, we must find first field and parse it. Set details to it and put in result array.
        ///
        
        /// NOTE: WHAT WE HAVE MISSED.
        /// We don't parse details for other blocks.
        /// It is next task.
        ///
        
        /// Find smartblock.
        /// 1. Group by .smartblock content.
        let splitted = DataStructures.GroupBy.group(blocks) { (lhs, rhs) -> Bool in
            switch (lhs.content, rhs.content) {
            case (.smartblock, .smartblock): return true
            case (.smartblock, _): return false
            case (_, .smartblock): return false
            default: return true
            }
        }
        
        /// We only care about two arrays.
        /// We assume that we have `only one` `smartblock`.
        /// Actually, we could have `smartblock` in the middle of split.
        /// But
        /// We assume that this is first block or last block and we have only 2 groups.
        ///
        /// TODO: Take into account 3 groups.
        ///
                
        /// 2. Find which is which and take it.
        
        let processBlock: ((Anytype_Model_Block?, [Anytype_Model_Block])) -> [Information] = { value  in
            let others = value.1
            if let block = value.0 {
                
                /// 1. Parse all blocks
                let result = self.parse(blocks: [block] + others)
                
                /// 2. Create a dictionary ( id -> information model )
                var idsAndInformation = Dictionary<String, Information>.init(uniqueKeysWithValues: result.compactMap({ value -> (String, Information) in
                    switch value.content {
                    case let .link(link): return (link.targetBlockID, value)
                    default: return (value.id, value)
                    }
                }))
                
                /// 3. Assign details to their links.
                details.forEach { (value) in
                    let correctedDetails = Converters.EventDetailsAndSetDetailsConverter.convert(event: value)
                    let informationDetails = Details.Converter.asModel(details: correctedDetails)
                    var correctInformation = idsAndInformation[value.id]
                    correctInformation?.pageDetails = .init(informationDetails)
                    
                    /// Don't forget that our information is a `struct`.
                    idsAndInformation[value.id] = correctInformation
                }
                
                return Array(idsAndInformation.values)
            }
            else {
                return []
            }
        }
        
        /// Another step: Go through all details and assign details to blocks.
        
        let smartblockAtBeginning = processBlock((splitted.first?.first, Array(splitted.dropFirst()).flatMap({$0})))
        if !smartblockAtBeginning.isEmpty {
            return smartblockAtBeginning
        }
        
        let smartblockAtEnd = processBlock((splitted.last?.first, Array(splitted.dropLast()).flatMap({$0})))
        if !smartblockAtEnd.isEmpty {
            return smartblockAtEnd
        }
        
        /// 3. Check that we have 3 groups.
        if splitted.count >= 3 {
            let logger = Logging.createLogger(category: .blockModelsParser)
            os_log(.debug, log: logger, "Our splitting has 3 or more parts. That means that we either have smartblocks in the middle of the array of blocks OR we have several smartblocks that ARE NOT in one group (or there is a block between them).")
        }
        
        let logger = Logging.createLogger(category: .blockModelsParser)
        os_log(.debug, log: logger, "In our parsing we can't find smartblock. It is unacceptable. Tell middleware about it.")
        return []
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
        
        var information = ConcreteInformation.init(id: block.id, content: blockType)

        // TODO: Add fields and restrictions.
        // Add parsers for them and model.
        let logger = Logging.createLogger(category: .todo(.improve("")))
        os_log(.debug, log: logger, "Add fields and restrictions and backgroundColor and align into our model.")
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
        os_log(.debug, log: logger, "Add fields and restrictions and backgroundColor and align into our model.")
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
extension Namespace.Parser {
    enum PublicConverters {
        enum EventsDetails {
            static func convert(event: Anytype_Event.Block.Set.Details) -> [Anytype_Rpc.Block.Set.Details.Detail] {
                Converters.EventDetailsAndSetDetailsConverter.convert(event: event)
            }
        }
    }
}

// MARK: - Converters / Common
private extension Namespace.Parser {
    /// It is a Converters Factory, actually.
    enum Converters {
        typealias BlockType = BlocksModels.Aliases.BlockContent
        static func convert(middleware: Anytype_Model_Block.OneOf_Content?) -> BaseContentConverter? {
            guard let middleware = middleware else { return nil }
            switch middleware {
            case .smartblock: return ContentSmartBlockAsEmptyPage()
            case .link: return ContentLink()
            case .text: return ContentText()
            case .file: return ContentFile()
            default: return nil
            }
        }
        static func convert(block: BlockType?) -> BaseContentConverter? {
            guard let block = block else { return nil }
            switch block {
            case .smartblock: return ContentSmartBlockAsEmptyPage()
            case .link: return ContentLink()
            case .text: return ContentText()
            case .file: return ContentFile()
            default: return nil
            }
        }
        class BaseContentConverter {
            open func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? { nil }
            open func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? { nil }
        }
    }
}

// MARK: Helper Converters / GoogleProtobufStructuresConverter
private extension Namespace.Parser.Converters {
    /// Convert (GoogleProtobufStruct) <-> (Dictionary<String, T>)
    /// NOTE: You should define `T` generic parameter. `Any` type for that purpose is bad.
    ///
    struct GoogleProtobufStructuresConverter {
        /// THINK: Possible solution - Add converters as function structures.
        struct AsStructure {
            
        }
        struct AsDictionary {
            
        }

        /// NOTE: Don't delete this code.
        /// You may need it.
        /// Actually, we don't have now correct conversion from our structure to protobuf.
        /// Look at `.structure` comments for details.
        ///
//        enum AllowedType {
//            case none
//            case string(String)
//            case number(Double)
//            case structure(AllowedType)
//            case
//        }
        struct HashableConverter {
            static func dictionary(_ from: Google_Protobuf_Struct) -> [String: AnyHashable] {
                (from.fields as? [String: AnyHashable]) ?? [:]
            }
            static func structure(_ from: [String: Any]) -> Google_Protobuf_Struct {
                return [:]
            }
        }
        
        static func dictionary(_ from: Google_Protobuf_Struct) -> [String: Any] {
            from.fields
        }
        static func structure(_ from: [String: Any]) -> Google_Protobuf_Struct {
            /// NOTE: Not implemented.
            /// Don't delete this code.
            /// Read comments below.
            ///
//            let fields = from.compactMapValues({ (value) in
//                Google_Protobuf_Any.init
//                try? Google_Protobuf_Value.init(unpackingAny: value)
//            })
            /// HowTo:
            /// We should use either our replica of GoogleProtobufStruct or we could use GoogleProtobufStruct directly.
            /// Look at GoogleProtobufStruct.kind property type. It has indirect cases which are impossible to store without full support of same Struct type.
            ///
            let logger = Logging.createLogger(category: .todo(.improve("")))
            os_log(.debug, log: logger, "Do not forget to add conversion from our model to protobuf sutrcture: %@", String(describing: from))
            return [:]
        }
    }
}

// MARK: Helper Converters / Details Converter
private extension Namespace.Parser.Converters {
    /// It seems that Middleware can't provide good model.
    /// So, we need to convert this models by ourselves.
    ///
    struct EventDetailsAndSetDetailsConverter {
        static func convert(event: Anytype_Event.Block.Set.Details) -> [Anytype_Rpc.Block.Set.Details.Detail] {
            event.details.fields.map(Anytype_Rpc.Block.Set.Details.Detail.init(key:value:))
        }
    }
}

/// TODO: Rethink parsing.
/// We should process Smartblocks correctly.
/// For now we are mapping them to our content type `.page` with style `.empty`
// MARK: ContentSmartBlock
private extension Namespace.Parser.Converters {
    class ContentSmartBlockAsEmptyPage: BaseContentConverter {
        func contentType(_ from: Anytype_Model_Block.Content.Smartblock) -> BlockType.Smartblock.Style? {
            .page
        }
        func style(_ from: BlockType.Smartblock.Style) -> Anytype_Model_Block.Content.Smartblock? {
            switch from {
            case .page:  return .init()
            case .home: return .init()
            case .profilePage: return .init()
            case .archive: return .init()
            case .breadcrumbs: return .init()
            }
        }
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
            case let .smartblock(value): return self.contentType(value).flatMap({.smartblock(.init(style: $0))})
            default: return nil
            }
        }
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .smartblock(value): return self.style(value.style).flatMap(Anytype_Model_Block.OneOf_Content.smartblock)
            default: return nil
            }
        }
    }
}


/// NOTE: Do not delete it before integration with new middleware and SetDetails refactoring.
/// Set Details task also contains some refactoring against current algorithm for parsing events.
/// Please, do not delete commented code.

//// MARK: ContentPage
//private extension BlockModels.Parser.Converters {
//    class ContentPage: BaseContentConverter {
//        func contentType(_ from: Anytype_Model_Block.Content.Page.Style) -> BlockType.Page.Style? {
//            switch from {
//            case .empty: return .empty
//            case .task: return .task
//            case .set: return .set
//            case .breadcrumbs: return nil
//            default: return nil
//            }
//        }
//        func style(_ from: BlockType.Page.Style) -> Anytype_Model_Block.Content.Page.Style? {
//            switch from {
//            case .empty: return .empty
//            case .task: return .task
//            case .set: return .set
//            }
//        }
//        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
//            switch from {
//            case let .page(value): return self.contentType(value.style).flatMap({BlockType.page(.init(style: $0))})
//            default: return nil
//            }
//        }
//        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
//            switch from {
//            case let .page(value): return self.style(value.style).flatMap({.page(.init(style: $0))})
//            default: return nil
//            }
//        }
//    }
//}

// MARK: ContentLink
private extension Namespace.Parser.Converters {
    /// Convert (Anytype_Model_Block.OneOf_Content) <-> (BlockType) for contentType `.link(_)`.
    class ContentLink: BaseContentConverter {
        private func contentType(_ from: Anytype_Model_Block.Content.Link.Style) -> BlockType.Link.Style? {
            switch from {
            case .page: return .page
            case .dataview: return .dataview
            case .dashboard: return nil
            case .archive: return nil
            default: return nil
            }
        }
        private func style(_ from: BlockType.Link.Style) -> Anytype_Model_Block.Content.Link.Style? {
            switch from {
            case .page: return .page
            case .dataview: return .dataview
            }
        }
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
            case let .link(value):
                let fields = GoogleProtobufStructuresConverter.HashableConverter.dictionary(value.fields)
                return self.contentType(value.style)
                    .flatMap({.link(.init(targetBlockID: value.targetBlockID, style: $0, fields: fields))})
            default: return nil
            }
        }
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .link(value):
                let fields = GoogleProtobufStructuresConverter.structure(value.fields)
                return self.style(value.style)
                    .flatMap({.link(.init(targetBlockID: value.targetBlockID, style: $0, fields: fields))})
            default: return nil
            }
        }
    }
}

// MARK: ContentText
private extension BlocksModels.Parser.Converters {
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
                case .checkbox: return .checkbox
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
            case .checkbox: return .checkbox
            case .bulleted: return .marked
            case .numbered: return .numbered
            case .toggle: return .toggle
            default: return nil
            }
        }
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
            case let .text(value): return self.contentType(value.style).flatMap({.text(.init(attributedText: BlockModels.Parser.Text.AttributedText.Converter.asModel(text: value.text, marks: value.marks), contentType: $0, color: value.color))})
            default: return nil
            }
        }
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .text(value): return self.style(value.contentType).flatMap({
                .text(.init(text: value.text, style: $0, marks: BlockModels.Parser.Text.AttributedText.Converter.asMiddleware(attributedText: value.attributedText).marks, checked: false, color: value.color))
                })
            default: return nil
            }
        }
    }
}

// MARK: ContentFile
private extension Namespace.Parser.Converters {
    class ContentFile: BaseContentConverter {
        func contentType(_ from: Anytype_Model_Block.Content.File.TypeEnum) -> BlockType.File.ContentType? {
            
            func result(_ from: Anytype_Model_Block.Content.File.TypeEnum) -> BlockType.File.ContentType? {
                
                // Only image support now
                switch from {
                case .image: return .image
                default: return nil
                }
            }
            
            func descriptive(_ from: Anytype_Model_Block.Content.File.TypeEnum) -> BlockType.File.ContentType? {
                let value = result(from)
                if value == nil {
                    let logger = Logging.createLogger(category: .todo(.improve("")))
                    os_log(.debug, log: logger, "Do not forget to add these entries in parser: %@", String(describing: from))
                }
                return value
            }
                  
            return descriptive(from)
        }
        
        func state(_ from: BlockType.File.State) -> Anytype_Model_Block.Content.File.State? {
            switch from {
                case .empty: return .empty
                case .uploading: return .uploading
                case .done: return .done
                case .error: return .error
                default: return nil
            }
        }
        
        func state(_ from: Anytype_Model_Block.Content.File.State) -> BlockType.File.State? {
            switch from {
                case .empty: return .empty
                case .uploading: return .uploading
                case .done: return .done
                case .error: return .error
                default: return nil
            }
        }
    
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
                case let .file(value):
                    guard let state = state(value.state) else { return nil }
                    return self.contentType(value.type).flatMap({.file(.init(name: value.name, hash: value.hash, state: state, contentType: $0))})
                default: return nil
            }
        }
        
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
                case let .file(value): return self.state(value.state).flatMap({ state in
                    var file = Anytype_Model_Block.Content.File()
                    file.type = .image
                    file.state = state
                    return Anytype_Model_Block.OneOf_Content.file(file)
                })
                default: return nil
            }
        }
      
    }
}
