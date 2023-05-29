import BlocksModels
import Foundation

protocol BlockMarkupChangerProtocol {
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId) -> NSAttributedString?
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString?
    func setMarkup(
        _ markup: MarkupType, blockId: BlockId, range: NSRange, currentText: NSAttributedString?
    ) -> NSAttributedString?
    func removeMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString?
}

// MARK: - Default values

extension BlockMarkupChangerProtocol {
    func setMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        setMarkup(markup, blockId: blockId, range: range, currentText: nil)
    }
}
