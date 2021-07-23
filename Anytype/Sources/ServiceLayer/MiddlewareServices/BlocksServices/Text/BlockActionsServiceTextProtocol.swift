import Foundation
import Combine
import UIKit
import BlocksModels


/// Protocol for TextBlockActions service.
protocol BlockActionsServiceTextProtocol {
    typealias Style = BlockText.Style
    
    func checked(contextId: BlockId, blockId: BlockId, newValue: Bool) -> AnyPublisher<ServiceSuccess, Error>
    func merge(contextID: BlockId, firstBlockID: BlockId, secondBlockID: BlockId) -> AnyPublisher<ServiceSuccess, Error>
    func split(contextID: BlockId, blockID: BlockId, range: NSRange, style: Style) -> AnyPublisher<ServiceSuccess, Error>
    
    /// Protocol for `SetTextColor` for text block.
    /// It is renamed intentionally.
    /// `SetForegroundColor` is something that you would expect from text.
    /// Lets describe how it would be done on top-level in UI updates.
    /// If you would like to apply `SetForegroundColor`, you would first create `attributedString` with content.
    /// And only after that, you would apply whole markup.
    /// It is easy to write in following:
    /// `precedencegroup` of SetForegroundColor is higher, than `precedencegroup` of `Set Text and Markup`
    /// But
    /// We also could do it via typing attributes.
    ///
    /// NOTE:
    /// This protocol requires two methods to be implemented. One of them uses UIColor as Color representation.
    /// It is essential for us to use `high-level` color.
    /// In that way we are distancing from low-level API and low-level colors.
    func setForegroundColor(contextID: BlockId, blockID: BlockId, color: String) -> AnyPublisher<Void, Error>
    
    /// Protocol for `SetStyle` for text block.
    /// It is used in `TurnInto` actions in UI.
    /// When you would like to update style of block ( or turn into this block to another block ),
    /// you will use this method.
    func setStyle(contextID: BlockId, blockID: BlockId, style: Style) -> AnyPublisher<ServiceSuccess, Error>
    
    // MARK: - Actions Protocols
    /// Protocol for `Set Text and Marks` for text block.
    /// NOTE: It has two methods. One of them accept high-level storage `NSAttributedString`
    /// It is necessary for us to have third part of communication between middleware.
    /// We consume middleware marks and convert them to NSAttributedString.
    /// Later, TextView update NSAttributedString and send updates back.
    ///
    @discardableResult
    func setText(contextID: BlockId, blockID: BlockId, attributedString: NSAttributedString) -> AnyPublisher<Void, Error>
    
    /// Toggle block markup for whole block string
    ///
    /// - Parameters:
    ///   - contextID: Document identifier,
    ///   - blockID: Block identifier
    ///   - style: Markup
    func toggleWholeBlockMarkup(
        contextID: BlockId,
        blockID: BlockId,
        style: MarkStyle
    ) -> AnyPublisher<ServiceSuccess, Error>?
}
