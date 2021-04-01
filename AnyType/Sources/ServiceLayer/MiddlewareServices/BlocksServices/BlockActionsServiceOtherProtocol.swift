import Foundation
import Combine
import BlocksModels

// MARK: - Actions Protocols
/// Protocol for set divider style.
protocol BlockActionsServiceOtherProtocolSetDividerStyle {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Style = TopLevel.AliasesMap.BlockContent.Divider.Style
    func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error>
}

// MARK: - Service Protocol
/// Protocol for Other blocks actions services.
protocol BlockActionsServiceOtherProtocol {
    associatedtype SetDividerStyle: BlockActionsServiceOtherProtocolSetDividerStyle
    var setDividerStyle: SetDividerStyle {get}
}
