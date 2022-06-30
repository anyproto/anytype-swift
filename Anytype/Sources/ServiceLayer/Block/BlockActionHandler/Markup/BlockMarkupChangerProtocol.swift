import BlocksModels
import Foundation

protocol BlockMarkupChangerProtocol {
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId) -> NSAttributedString?
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString?
    func setMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString?
    func removeMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString?
}
