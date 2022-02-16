import BlocksModels

struct BlockRestrictionsBuilder {
    
    static func build(content: BlockContent) -> BlockRestrictions {
        build(contentType: content.type)
    }
    
    static func build(contentType: BlockContentType) -> BlockRestrictions {
        switch contentType {
        case let .text(text):
            return build(textContentType: text)
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
        case .smartblock, .layout, .featuredRelations, .dataView:
            return DummyRestrictions()
        case .relation:
            return RelationBlockRestrictions()
        }
    }
    
    static func build(textContentType: BlockText.Style) -> BlockRestrictions {
        switch textContentType {
        case .text, .callout:
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
