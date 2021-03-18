//
//  BlocksModelsModule+Parser+Content.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.07.2020.
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

// MARK: Helper Converters / GoogleProtobufStructuresConverter
extension FileNamespace.Converters {
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
                from.fields
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
extension FileNamespace.Converters {
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
extension FileNamespace.Converters {
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
extension FileNamespace.Converters {
    /// Convert (Anytype_Model_Block.OneOf_Content) <-> (BlockType) for contentType `.link(_)`.
    class ContentLink: BaseContentConverter {
        fileprivate typealias Link = FileNamespace.Link
        fileprivate typealias StyleConverter = Link.Style.Converter
        
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
            case let .link(value):
                let fields = GoogleProtobufStructuresConverter.HashableConverter.dictionary(value.fields)
                return StyleConverter.asModel(value.style)
                    .flatMap({.link(.init(targetBlockID: value.targetBlockID, style: $0, fields: fields))})
            default: return nil
            }
        }
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .link(value):
                let fields = GoogleProtobufStructuresConverter.structure(value.fields)
                return StyleConverter.asMiddleware(value.style)
                    .flatMap({.link(.init(targetBlockID: value.targetBlockID, style: $0, fields: fields))})
            default: return nil
            }
        }
    }
}

// MARK: - ContentText

extension FileNamespace.Converters {
    class ContentText: BaseContentConverter {
        fileprivate typealias TextConverter = FileNamespace.Text
        fileprivate typealias ContentTypeConverter = TextConverter.ContentType.Converter
        
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
            case let .text(value):
                return ContentTypeConverter.asModel(value.style).flatMap {
                    typealias Text = Block.Content.ContentType.Text
                    let attributedString = TextConverter.AttributedText.Converter.asModel(text: value.text, marks: value.marks, color: value.color)
                    let textContent: Text = .init(attributedText: attributedString, color: value.color, contentType: $0, checked: value.checked)
                    return .text(textContent)
                }
            default: return nil
            }
        }
        
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .text(value): return ContentTypeConverter.asMiddleware(value.contentType).flatMap({
                .text(.init(text: value.attributedText.string, style: $0, marks: FileNamespace.Text.AttributedText.Converter.asMiddleware(attributedText: value.attributedText).marks, checked: value.checked, color: value.color))
                })
            default: return nil
            }
        }
    }
}

// MARK: ContentFile
extension FileNamespace.Converters {
    class ContentFile: BaseContentConverter {
        fileprivate typealias File = FileNamespace.File
        fileprivate typealias TypeEnumConverter = File.ContentType.Converter
        fileprivate typealias StateConverter = File.State.Converter
    
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
                case let .file(value):
                    guard let state = StateConverter.asModel(value.state) else { return nil }
                    return TypeEnumConverter.asModel(value.type).flatMap({.file(.init(metadata: .init(name: value.name, size: value.size, hash: value.hash, mime: value.mime, addedAt: value.addedAt), contentType: $0, state: state))})
                default: return nil
            }
        }
        
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
                case let .file(value):
                    let metadata = value.metadata
                    guard let state = StateConverter.asMiddleware(value.state) else { return nil }
                    return TypeEnumConverter.asMiddleware(value.contentType).flatMap({.file(.init(hash: metadata.hash, name: metadata.name, type: $0, mime: metadata.mime, size: metadata.size, addedAt: 0, state: state))})
                default: return nil
            }
        }
      
    }
}

// MARK: ContentBookmark
extension FileNamespace.Converters {
    class ContentBookmark: BaseContentConverter {
        fileprivate typealias Bookmark = FileNamespace.Bookmark
        fileprivate typealias TypeEnumConverter = Bookmark.TypeEnum.Converter
        
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
            case let .bookmark(value): return TypeEnumConverter.asModel(value.type).flatMap({.bookmark(.init(url: value.url, title: value.title, theDescription: value.description_p, imageHash: value.imageHash, faviconHash: value.faviconHash, type: $0))})
            default: return nil
            }
        }
        
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .bookmark(value): return TypeEnumConverter.asMiddleware(value.type).flatMap({.bookmark(.init(url: value.url, title: value.title, description_p: value.theDescription, imageHash: value.imageHash, faviconHash: value.faviconHash, type: $0))})
            default: return nil
            }
        }
    }
}

// MARK: ContentDivider
extension FileNamespace.Converters {
    class ContentDivider: BaseContentConverter {
        fileprivate typealias Divider = FileNamespace.Other.Divider
        fileprivate typealias StyleConverter = Divider.Style.Converter
        
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
            case let .div(value): return StyleConverter.asModel(value.style).flatMap({ .divider(.init(style: $0)) })
            default: return nil
            }
        }
        
        override func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .divider(value): return StyleConverter.asMiddleware(value.style).flatMap({ .div(.init(style: $0)) })
            default: return nil
            }
        }
    }
}

// MARK: ContentLayout
extension FileNamespace.Converters {
    class ContentLayout: BaseContentConverter {
        fileprivate typealias Layout = FileNamespace.Layout
        fileprivate typealias StyleConverter = Layout.Style.Converter
        
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
            switch from {
            case let .layout(value): return StyleConverter.asModel(value.style).flatMap({ .layout(.init(style: $0)) })
            default: return nil
            }
        }
        
        override func middleware(_ from: BlocksModelsModule.Parser.Converters.BlockType?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .layout(value): return StyleConverter.asMiddleware(value.style).flatMap({ .layout(.init(style: $0)) })
            default: return nil
            }
        }
    }
}
