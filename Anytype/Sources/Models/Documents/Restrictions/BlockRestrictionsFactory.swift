
import BlocksModels

struct BlockRestrictionsFactory {
    
    func makeRestrictions(for contentType: BlockContent) -> BlockRestrictions {
        self.makeRestrictions(for: contentType.type)
    }
    
    func makeRestrictions(for contentType: BlockContentType) -> BlockRestrictions {
        switch contentType {
        case let .text(text):
            return makeTextRestrictions(for: text)
        case .divider:
            return DividerBlockRestrictions()
        case let .file(contentType):
            switch contentType {
            case .image:
                return ImageBlockRestrictions()
            default:
                return FileBlockRestrictions()
            }
            
        case .link:
            return PageBlockRestrictions()
        case .bookmark:
            return BookmarkBlockRestrictions()
        case .smartblock, .layout, .featuredRelations:
            return DummyRestrictions()
        }
    }
    
    func makeTextRestrictions(for contentType: BlockText.Style) -> BlockRestrictions {
        switch contentType {
        case .text:
            return TextBlockRestrictions()
        case .title, .description:
            return TitleBlockRestrictions()
        case .header, .header2, .header3, .header4:
            return HeaderBlockRestrictions()
        case .bulleted, .numbered, .toggle, .checkbox:
            return ListBlockRestrictions()
        case .quote:
            return HighlightedBlockRestrictions()
        case .code:
            return CodeBlockRestrictions()
        }
    }
}
