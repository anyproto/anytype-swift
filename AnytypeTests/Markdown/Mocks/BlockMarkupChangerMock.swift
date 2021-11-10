@testable import Anytype
@testable import BlocksModels
import Foundation

final class BlockMarkupChangerMock: BlockMarkupChangerProtocol {
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId) -> NSAttributedString? {
        assertionFailure()
        return nil
    }
    
    var toggleMarkupInRangeStubReturnString: NSAttributedString?
    var toggleMarkupInRangeLastMarkupType: MarkupType?
    var toggleMarkupInRangeNumberOfCalls = 0
    var toggleMarkupInRangeLastRange: NSRange?
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        if let string = toggleMarkupInRangeStubReturnString {
            toggleMarkupInRangeLastMarkupType = markup
            toggleMarkupInRangeLastRange = range
            toggleMarkupInRangeNumberOfCalls += 1
            return string
        } else {
            assertionFailure()
            return nil
        }
    }
    
    func setMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        assertionFailure()
        return nil
    }
    
    func removeMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        assertionFailure()
        return nil
    }
}
