import Services
import Foundation

protocol BlockMarkupChangerProtocol {
    func toggleMarkup(_ markup: MarkupType, blockId: String) -> NSAttributedString?
    func toggleMarkup(_ markup: MarkupType, blockId: String, range: NSRange) -> NSAttributedString?
    func setMarkup(
        _ markup: MarkupType, blockId: String, range: NSRange, currentText: NSAttributedString?
    ) -> NSAttributedString?
    func removeMarkup(_ markup: MarkupType, blockId: String, range: NSRange) -> NSAttributedString?
}

// MARK: - Default values

extension BlockMarkupChangerProtocol {
    func setMarkup(_ markup: MarkupType, blockId: String, range: NSRange) -> NSAttributedString? {
        setMarkup(markup, blockId: blockId, range: range, currentText: nil)
    }
}
