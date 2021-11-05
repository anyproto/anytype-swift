import BlocksModels


protocol BlockMarkupChangerProtocol {
    
    func toggleMarkup(_ markup: TextAttributesType, for blockId: BlockId)
    
    func toggleMarkup(_ markup: TextAttributesType, for blockId: BlockId, in range: NSRange)
    
    func setLink(_ link: URL?, for blockId: BlockId, in range: NSRange)

    func setLinkToObject(id: BlockId, for blockId: BlockId, in range: NSRange)
}
