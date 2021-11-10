@testable import Anytype
@testable import BlocksModels
import Foundation

final class BlockMarkupChangerMock: BlockMarkupChangerProtocol {
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId) -> NSAttributedString? {
        assertionFailure()
        return nil
    }
    
    func toggleMarkup(_ markup: MarkupType, blockId: BlockId, range: NSRange) -> NSAttributedString? {
        assertionFailure()
        return nil
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
