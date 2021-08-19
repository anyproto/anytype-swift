import BlocksModels

protocol BlockMarkupChangerProtocol {
    
    func toggleMarkup(
        _ markup: BlockHandlerActionType.TextAttributesType,
        for blockId: BlockId,
        in range: NSRange
    )
    
    func setLink(
        _ link: URL?,
        for blockId: BlockId,
        in range: NSRange
    )
}
