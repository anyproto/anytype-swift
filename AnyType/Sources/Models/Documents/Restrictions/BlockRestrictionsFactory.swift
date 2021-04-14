
import BlocksModels

struct BlockRestrictionsFactory {
    
    func makeRestrictions(for contentType: BlockContent) -> BlockRestrictions {
        switch contentType {
        case let .text(text):
            return self.makeTextRestrictions(for: text.contentType)
        case .divider:
            return DividerBlockRestrictions()
        case .file:
            return FileBlockRestrictions()
        case .link:
            return PageBlockRestrictions()
        case .bookmark:
            return BookmarkBlockRestrictions()
        case .smartblock, .layout:
            assertionFailure("No restrictions for smartblock and layout")
            return TextBlockRestrictions()
        }
    }
    
    func makeTextRestrictions(for contentType: BlockContent.Text.ContentType) -> BlockRestrictions {
        switch contentType {
        case .text:
            return TextBlockRestrictions()
        case .title, .header, .header2, .header3, .header4:
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
