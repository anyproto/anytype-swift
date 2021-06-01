import ProtobufMessages
import BlocksModels

/// We should process Smartblocks correctly.
/// For now we are mapping them to our content type `.page` with style `.empty`
final class ContentObjectAsEmptyPage {
    func blockType(_ from: Anytype_Model_Block.Content.Smartblock) -> BlockContent {
        return .smartblock(.init(style: BlockContent.Smartblock.Style.page))
    }
    
    func middleware(_ from: BlockContent.Smartblock) -> Anytype_Model_Block.OneOf_Content {
        return Anytype_Model_Block.OneOf_Content.smartblock(style(from.style))
    }
    
    private func style(_ from: BlockContent.Smartblock.Style) -> Anytype_Model_Block.Content.Smartblock {
        switch from {
        case .page:  return .init()
        case .home: return .init()
        case .profilePage: return .init()
        case .archive: return .init()
        case .breadcrumbs: return .init()
        }
    }
}
