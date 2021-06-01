import Foundation
import Combine
import BlocksModels
import UIKit

protocol BlockActionsServiceListProtocol {
    typealias DividerStyle = BlockContent.Divider.Style
    typealias TextStyle = BlockContent.Text.ContentType
    typealias Alignment = BlockInformation.Alignment
    typealias Field = String
    
    func delete(blockIds: [String]) -> AnyPublisher<ServiceSuccess, Error>
    func delete(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<ServiceSuccess, Error>
    func setPageIsArchived(contextID: BlockId, blockIds: [BlockId], isArchived: Bool) -> AnyPublisher<ServiceSuccess, Error>
    func setDivStyle(contextID: BlockId, blockIds: [BlockId], style: DividerStyle) -> AnyPublisher<ServiceSuccess, Error>
    func setAlign(contextID: BlockId, blockIds: [BlockId], alignment: Alignment) -> AnyPublisher<ServiceSuccess, Error>
    func setBackgroundColor(contextID: BlockId, blockIds: [BlockId], color: String) -> AnyPublisher<ServiceSuccess, Error>
    func setTextStyle(contextID: BlockId, blockIds: [BlockId], style: TextStyle) -> AnyPublisher<ServiceSuccess, Error>
    func setFields(contextID: BlockId, blockFields: [BlockFields]) -> AnyPublisher<ServiceSuccess, Error>
    func setBlockColor(contextID: BlockId, blockIds: [BlockId], color: String) -> AnyPublisher<ServiceSuccess, Error>
}
