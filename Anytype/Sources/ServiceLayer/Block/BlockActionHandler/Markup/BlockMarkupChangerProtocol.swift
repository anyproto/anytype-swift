import BlocksModels

protocol BlockMarkupChangerProtocol {
    func toggleMarkup(_ markup: MarkupType, for blockId: BlockId)
    func toggleMarkup(_ markup: MarkupType, for blockId: BlockId, in range: NSRange)
    func setMarkup(_ markup: MarkupType, for blockId: BlockId, in range: NSRange)
    func removeMarkup(_ markup: MarkupType, for blockId: BlockId, in range: NSRange)
}
