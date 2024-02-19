@testable import Anytype
@testable import Services
import Foundation

final class BlockMarkupChangerMock: BlockMarkupChangerProtocol {
    
    func toggleMarkup(_ markup: MarkupType, blockId: String) -> NSAttributedString? {
        assertionFailure()
        return nil
    }
    
    func toggleMarkup(_ markup: MarkupType, blockId: String, range: NSRange) -> NSAttributedString? {
        assertionFailure()
        return nil
    }
    
    var setMarkupStubReturnString: NSAttributedString?
    var setMarkupLastMarkupType: MarkupType?
    var setMarkupNumberOfCalls = 0
    var setMarkupLastRange: NSRange?
    func setMarkup(_ markup: MarkupType, blockId: String, range: NSRange, currentText: NSAttributedString?) -> NSAttributedString? {
        if let string = setMarkupStubReturnString {
            setMarkupLastMarkupType = markup
            setMarkupLastRange = range
            setMarkupNumberOfCalls += 1
            return string
        } else {
            assertionFailure()
            return nil
        }
    }
    
    func removeMarkup(_ markup: MarkupType, blockId: String, range: NSRange) -> NSAttributedString? {
        assertionFailure()
        return nil
    }
}
