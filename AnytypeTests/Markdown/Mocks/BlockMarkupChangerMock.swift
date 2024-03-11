@testable import Anytype
@testable import Services
import Foundation

final class BlockMarkupChangerMock: BlockMarkupChangerProtocol {
    func toggleMarkup(_ attributedString: NSAttributedString, markup: MarkupType, contentType: BlockContentType) -> NSAttributedString {
        assertionFailure()
        return NSAttributedString()
    }
    
    func toggleMarkup(_ attributedString: NSAttributedString, markup: MarkupType, range: NSRange, contentType: BlockContentType) -> NSAttributedString {
        assertionFailure()
        return NSAttributedString()
    }
    
    var setMarkupStubReturnString: NSAttributedString?
    var setMarkupLastMarkupType: MarkupType?
    var setMarkupNumberOfCalls = 0
    var setMarkupLastRange: NSRange?
    func setMarkup(_ markup: MarkupType, range: NSRange, attributedString: NSAttributedString, contentType: BlockContentType) -> NSAttributedString {
        if let string = setMarkupStubReturnString {
            setMarkupLastMarkupType = markup
            setMarkupLastRange = range
            setMarkupNumberOfCalls += 1
            return string
        } else {
            assertionFailure()
            return NSAttributedString()
        }
    }
    
    func removeMarkup(_ markup: MarkupType, range: NSRange, contentType: BlockContentType, attributedString: NSAttributedString) -> NSAttributedString {
        assertionFailure()
        return NSAttributedString()
    }
}
