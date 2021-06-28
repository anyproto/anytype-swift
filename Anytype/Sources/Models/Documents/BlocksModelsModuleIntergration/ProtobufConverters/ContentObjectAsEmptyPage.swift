import ProtobufMessages
import BlocksModels

final class ContentObjectAsEmptyPage {
    func blockType(_ from: Anytype_Model_Block.Content.Smartblock) -> BlockContent {
        return .smartblock(.init(style: BlockSmartblock.Style.page))
    }
    
    func middleware(_ from: BlockSmartblock) -> Anytype_Model_Block.OneOf_Content {
        return Anytype_Model_Block.OneOf_Content.smartblock(style(from.style))
    }
    
    private func style(_ from: BlockSmartblock.Style) -> Anytype_Model_Block.Content.Smartblock {
        switch from {
        case .page:  return .init()
        case .home: return .init()
        case .profilePage: return .init()
        case .archive: return .init()
        case .breadcrumbs: return .init()
        }
    }
}
