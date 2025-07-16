public struct BlockRestrictionsBuilder: Sendable {
    
    public static func build(content: BlockContent) -> BlockRestrictions {
        build(contentType: content.type)
    }
    
    public static func build(contents: [BlockContent]) -> BlockRestrictions {
        let restrictions = contents.map { Self.build(content: $0) }
        return MerdgedBlockRestrictions(blockRestrictions: restrictions)
    }
    
    public static func build(contentType: BlockContentType) -> BlockRestrictions {
        switch contentType {
        case let .text(text):
            return build(textContentType: text)
        case .divider:
            return DividerBlockRestrictions()
        case let .file(data):
            switch data.contentType {
            case .image:
                return ImageBlockRestrictions()
            default:
                return FileBlockRestrictions()
            }
            
        case .link:
            return PageBlockRestrictions()
        case .bookmark:
            return BookmarkBlockRestrictions()
        case .smartblock, .layout, .featuredRelations, .dataView, .table, .tableRow, .tableColumn, .widget, .chat, .embed:
            return DummyRestrictions()
        case .relation:
            return PropertyBlockRestrictions()
        case .tableOfContents:
            return TableOfContentsRestrictions()
        }
    }
    
    public static func build(textContentType: BlockText.Style) -> BlockRestrictions {
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

private struct MerdgedBlockRestrictions: BlockRestrictions {
    let canApplyBold: Bool
    let canApplyItalic: Bool
    let canApplyOtherMarkup: Bool
    let canApplyBlockColor: Bool
    let canApplyBackgroundColor: Bool
    let canApplyMention: Bool
    let canApplyEmoji: Bool
    let canDeleteOrDuplicate: Bool
    let turnIntoStyles: [Services.BlockContentType]
    let availableAlignments: [Services.LayoutAlignment]
    
    init(blockRestrictions: [BlockRestrictions]) {
        self.canApplyBold = Self.merge(blockRestrictions, transfrom: { $0.canApplyBold })
        self.canApplyItalic = Self.merge(blockRestrictions, transfrom: { $0.canApplyItalic })
        self.canApplyOtherMarkup = Self.merge(blockRestrictions, transfrom: { $0.canApplyOtherMarkup })
        self.canApplyBlockColor = Self.merge(blockRestrictions, transfrom: { $0.canApplyBlockColor })
        self.canApplyBackgroundColor = Self.merge(blockRestrictions, transfrom: { $0.canApplyBackgroundColor })
        self.canApplyMention = Self.merge(blockRestrictions, transfrom: { $0.canApplyMention })
        self.canApplyEmoji = Self.merge(blockRestrictions, transfrom: { $0.canApplyEmoji })
        self.canDeleteOrDuplicate = Self.merge(blockRestrictions, transfrom: { $0.canDeleteOrDuplicate })
        
        let textBlockRestrictions = TextBlockRestrictions()
        self.turnIntoStyles = Array(
            blockRestrictions
                .map { Set($0.turnIntoStyles) }
                .reduce(Set(textBlockRestrictions.turnIntoStyles)) { $0.intersection($1) }
        )
        self.availableAlignments = Array(
            blockRestrictions
                .map { Set($0.availableAlignments) }
                .reduce(Set(textBlockRestrictions.availableAlignments)) { $0.intersection($1) }
        )
    }
    
    private static func merge(_ blockRestrictions: [BlockRestrictions], transfrom: (BlockRestrictions) -> Bool) -> Bool {
        blockRestrictions.map(transfrom).reduce(true) { $0 && $1 }
    }
    
}
