import ProtobufMessages
import BlocksModels

extension BlocksModelsParser {
    enum PublicConverters {
        enum EventsDetails {
            static func convert(event: Anytype_Event.Object.Details.Set) -> [Anytype_Rpc.Block.Set.Details.Detail] {
                Converters.EventDetailsAndSetDetailsConverter.convert(event: event)
            }
        }
    }
}

extension BlocksModelsParser {
    enum Converters {
        class BaseContentConverter {
            open func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockContent? { nil }
            open func middleware(_ from: BlockContent?) -> Anytype_Model_Block.OneOf_Content? { nil }
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

    static func convert(block: BlockContent?) -> BaseContentConverter? {
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
