import ProtobufMessages
import BlocksModels

extension BlocksModelsParser {
    enum PublicConverters {
        enum EventsDetails {
            static func convert(event: Anytype_Event.Block.Set.Details) -> [Anytype_Rpc.Block.Set.Details.Detail] {
                Converters.EventDetailsAndSetDetailsConverter.convert(event: event)
            }
        }
    }
}

extension BlocksModelsParser {
    enum Converters {
        typealias BlockType = OurContent
        class BaseContentConverter {
            open func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? { nil }
            open func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? { nil }
        }
    }
}

// MARK: - Converters / Common
extension BlocksModelsParser.Converters {
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
