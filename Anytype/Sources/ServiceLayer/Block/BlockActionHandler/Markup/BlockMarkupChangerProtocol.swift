import Services
import Foundation

protocol BlockMarkupChangerProtocol {
    func toggleMarkup(
        _ attributedString: NSAttributedString,
        markup: MarkupType,
        contentType: BlockContentType
    ) -> NSAttributedString
    
    func toggleMarkup(
        _ attributedString: NSAttributedString,
        markup: MarkupType,
        range: NSRange,
        contentType: BlockContentType
    ) -> NSAttributedString
    
    func setMarkup(
        _ markup: MarkupType,
        range: NSRange,
        attributedString: NSAttributedString,
        contentType: BlockContentType
    ) -> NSAttributedString
    
    func removeMarkup(
        _ markup: MarkupType,
        range: NSRange,
        contentType: BlockContentType,
        attributedString: NSAttributedString
    ) -> NSAttributedString
}
