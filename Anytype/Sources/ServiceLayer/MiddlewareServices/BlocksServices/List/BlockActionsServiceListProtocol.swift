import Foundation
import Combine
import BlocksModels
import UIKit

protocol BlockActionsServiceListProtocol {
    typealias DividerStyle = BlockDivider.Style
    typealias TextStyle = BlockText.Style
    typealias Alignment = LayoutAlignment
    typealias Field = String
    
    func delete(blockIds: [String]) -> AnyPublisher<ServiceSuccess, Error>
    func setPageIsArchived(contextID: BlockId, blockIds: [BlockId], isArchived: Bool) -> AnyPublisher<ServiceSuccess, Error>
    func setDivStyle(contextID: BlockId, blockIds: [BlockId], style: DividerStyle) -> AnyPublisher<ServiceSuccess, Error>
    func setAlign(contextID: BlockId, blockIds: [BlockId], alignment: Alignment) -> AnyPublisher<ServiceSuccess, Error>
    func setBackgroundColor(contextID: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> AnyPublisher<ServiceSuccess, Error>
    func setTextStyle(contextID: BlockId, blockIds: [BlockId], style: TextStyle) -> AnyPublisher<ServiceSuccess, Error>
    func setFields(contextID: BlockId, blockFields: [BlockFields]) -> AnyPublisher<ServiceSuccess, Error>
    func setBlockColor(contextID: BlockId, blockIds: [BlockId], color: MiddlewareColor) -> AnyPublisher<ServiceSuccess, Error>
}
