import ProtobufMessages

public extension Anytype_Model_Block.Content.Smartblock {
    var blockContent: BlockContent {
        .smartblock(.init(style: BlockSmartblock.Style.page))
    }
}

public extension BlockSmartblock {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        Anytype_Model_Block.OneOf_Content.smartblock(style.asMiddleware)
    }
}

public extension BlockSmartblock.Style {
    var asMiddleware: Anytype_Model_Block.Content.Smartblock {
        switch self {
        case .page:  return .init()
        case .home: return .init()
        case .profilePage: return .init()
        case .archive: return .init()
        case .breadcrumbs: return .init()
        }
    }
}
