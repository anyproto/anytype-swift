import BlocksModels

protocol BlockMarkupChangerProtocol {
    
    func toggleMarkup(
        _ markup: BlockHandlerActionType.TextAttributesType,
        for blockId: BlockId
    )
    
    func toggleMarkup(
        _ markup: BlockHandlerActionType.TextAttributesType,
        attributedText: NSAttributedString,
        for blockId: BlockId,
        in range: NSRange
    )
    
    func setLink(
        _ link: URL?,
        attributedText: NSAttributedString,
        for blockId: BlockId,
        in range: NSRange
    )
}
