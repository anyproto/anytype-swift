import Foundation
import SwiftProtobuf
import os
import BlocksModels
import ProtobufMessages


// MARK: Helper Converters / GoogleProtobufStructuresConverter
extension BlocksModelsParser.Converters {
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
            assertionFailure("Do not forget to add conversion from our model to protobuf sutrcture: \(from)")
            return [:]
        }
    }
}

// MARK: Helper Converters / Details Converter
extension BlocksModelsParser.Converters {
    /// It seems that Middleware can't provide good model.
    /// So, we need to convert this models by ourselves.
    ///
    struct EventDetailsAndSetDetailsConverter {
        static func convert(event: Anytype_Event.Object.Details.Set) -> [Anytype_Rpc.Block.Set.Details.Detail] {
            event.details.fields.map(Anytype_Rpc.Block.Set.Details.Detail.init(key:value:))
        }
    }
}

/// TODO: Rethink parsing.
/// We should process Smartblocks correctly.
/// For now we are mapping them to our content type `.page` with style `.empty`
extension BlocksModelsParser.Converters {
    final class ContentObjectAsEmptyPage: BaseContentConverter {
        func contentType(_ from: Anytype_Model_Block.Content.Smartblock) -> BlockContent.Smartblock.Style? {
            .page
        }
        func style(_ from: BlockContent.Smartblock.Style) -> Anytype_Model_Block.Content.Smartblock? {
            switch from {
            case .page:  return .init()
            case .home: return .init()
            case .profilePage: return .init()
            case .archive: return .init()
            case .breadcrumbs: return .init()
            }
        }
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockContent? {
            switch from {
            case let .smartblock(value): return self.contentType(value).flatMap({.smartblock(.init(style: $0))})
            default: return nil
            }
        }
        override func middleware(_ from: BlockContent?) -> Anytype_Model_Block.OneOf_Content? {
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
extension BlocksModelsParser.Converters {
    /// Convert (Anytype_Model_Block.OneOf_Content) <-> (BlockType) for contentType `.link(_)`.
    class ContentLink: BaseContentConverter {
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockContent? {
            switch from {
            case let .link(value):
                let fields = GoogleProtobufStructuresConverter.HashableConverter.dictionary(value.fields)
                return BlocksModelsParserLinkStyleConverter.asModel(value.style)
                    .flatMap({.link(.init(targetBlockID: value.targetBlockID, style: $0, fields: fields))})
            default: return nil
            }
        }
        override func middleware(_ from: BlockContent?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .link(value):
                let fields = GoogleProtobufStructuresConverter.structure(value.fields)
                return BlocksModelsParserLinkStyleConverter.asMiddleware(value.style)
                    .flatMap({.link(.init(targetBlockID: value.targetBlockID, style: $0, fields: fields))})
            default: return nil
            }
        }
    }
}

// MARK: - ContentText

extension BlocksModelsParser.Converters {
    class ContentText: BaseContentConverter {
        
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockContent? {
            switch from {
            case let .text(value):
                return BlocksModelsParserTextContentTypeConverter.asModel(value.style).flatMap {
                    typealias Text = BlockContent.Text
                    let attributedString = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter.asModel(
                        text: value.text,
                        marks: value.marks,
                        style: value.style
                    )
                    let textContent: Text = .init(
                        attributedText: attributedString, color: value.color, contentType: $0, checked: value.checked
                    )
                    return .text(textContent)
                }
            default: return nil
            }
        }
        
        override func middleware(_ from: BlockContent?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .text(value):
                let style = BlocksModelsParserTextContentTypeConverter.asMiddleware(value.contentType)
                return.text(
                    .init(
                        text: value.attributedText.string,
                        style: style,
                        marks: MiddlewareModelsModule.Parsers.Text.AttributedText.Converter.asMiddleware(
                            attributedText: value.attributedText
                        ).marks,
                        checked: value.checked,
                        color: value.color
                    ))
            default: return nil
            }
        }
    }
}

// MARK: ContentFile
extension BlocksModelsParser.Converters {
    class ContentFile: BaseContentConverter {
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockContent? {
            switch from {
                case let .file(value):
                    guard let state = BlocksModelsParserFileStateConverter.asModel(value.state) else { return nil }
                    return BlocksModelsParserFileContentTypeConverter.asModel(value.type).flatMap(
                        {.file(.init(
                                metadata: .init(
                                    name: value.name,
                                    size: value.size,
                                    hash: value.hash,
                                    mime: value.mime,
                                    addedAt: value.addedAt
                                ),
                                contentType: $0, state: state)
                        )}
                    )
                default: return nil
            }
        }
        
        override func middleware(_ from: BlockContent?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
                case let .file(value):
                    let metadata = value.metadata
                    guard let state = BlocksModelsParserFileStateConverter.asMiddleware(value.state) else { return nil }
                    return BlocksModelsParserFileContentTypeConverter.asMiddleware(value.contentType).flatMap(
                        {.file(.init(
                                hash: metadata.hash,
                                name: metadata.name,
                                type: $0,
                                mime: metadata.mime,
                                size: metadata.size,
                                addedAt: 0,
                                state: state
                        ))}
                    )
                default: return nil
            }
        }
      
    }
}

// MARK: ContentBookmark
extension BlocksModelsParser.Converters {
    class ContentBookmark: BaseContentConverter {
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockContent? {
            switch from {
            case let .bookmark(value):
                return BlocksModelsParserBookmarkTypeEnumConverter.asModel(value.type).flatMap(
                    {.bookmark(.init(url: value.url, title: value.title, theDescription: value.description_p, imageHash: value.imageHash, faviconHash: value.faviconHash, type: $0))}
                )
            default: return nil
            }
        }
        
        override func middleware(_ from: BlockContent?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .bookmark(value):
                return BlocksModelsParserBookmarkTypeEnumConverter.asMiddleware(value.type).flatMap(
                    {.bookmark(.init(url: value.url, title: value.title, description_p: value.theDescription, imageHash: value.imageHash, faviconHash: value.faviconHash, type: $0))}
                )
            default: return nil
            }
        }
    }
}

// MARK: ContentDivider
extension BlocksModelsParser.Converters {
    class ContentDivider: BaseContentConverter {
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockContent? {
            switch from {
            case let .div(value): return BlocksModelsParserOtherDividerStyleConverter.asModel(value.style).flatMap({ .divider(.init(style: $0)) })
            default: return nil
            }
        }
        
        override func middleware(_ from: BlockContent?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .divider(value): return BlocksModelsParserOtherDividerStyleConverter.asMiddleware(value.style).flatMap({ .div(.init(style: $0)) })
            default: return nil
            }
        }
    }
}

// MARK: ContentLayout
extension BlocksModelsParser.Converters {
    class ContentLayout: BaseContentConverter {        
        override func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockContent? {
            switch from {
            case let .layout(value):
                return BlocksModelsParserLayoutStyleConverter.asModel(value.style).flatMap({ .layout(.init(style: $0)) })
            default: return nil
            }
        }
        
        override func middleware(_ from: BlockContent?) -> Anytype_Model_Block.OneOf_Content? {
            switch from {
            case let .layout(value):
                return BlocksModelsParserLayoutStyleConverter.asMiddleware(value.style).flatMap({ .layout(.init(style: $0)) })
            default: return nil
            }
        }
    }
}
