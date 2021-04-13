import Foundation
import Combine
import BlocksModels
import UIKit

protocol BlockActionsServiceListProtocolDelete {
    associatedtype Success
    func action(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<Success, Error>
}

/// We don't support fields now.
protocol BlockActionsServiceListProtocolSetFields {
    associatedtype Success
    /// TODO: Add our fields model.
    typealias Field = String
    func action(contextID: BlockId, blockFields: [String]) -> AnyPublisher<Success, Error>
//    func action(contextID: BlockId, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) -> AnyPublisher<Success, Error>
}

protocol BlockActionsServiceListProtocolSetTextStyle {
    associatedtype Success
    typealias Style = BlockContent.Text.ContentType
    func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error>
}
// TODO: Later enable it and remove old services that works with Duplicates.
//protocol BlockActionsServiceListProtocolDuplicate {
//    associatedtype Success
//    func action() -> AnyPublisher<Success, Error>
//}
protocol BlockActionsServiceListProtocolSetBackgroundColor {
    associatedtype Success
    func action(contextID: BlockId, blockIds: [BlockId], color: String) -> AnyPublisher<Success, Error>
}
protocol BlockActionsServiceListProtocolSetAlign {
    associatedtype Success
    typealias Alignment = BlockInformation.Alignment
    func action(contextID: BlockId, blockIds: [BlockId], alignment: Alignment) -> AnyPublisher<Success, Error>
}
protocol BlockActionsServiceListProtocolSetDivStyle {
    associatedtype Success
    typealias Style = BlockContent.Divider.Style
    func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error>
}
protocol BlockActionsServiceListProtocolSetPageIsArchived {
    associatedtype Success
    func action(contextID: BlockId, blockIds: [BlockId], isArchived: Bool) -> AnyPublisher<Success, Error>
}
protocol BlockActionsServiceListProtocolDeletePage {
    associatedtype Success
    func action(blockIds: [String]) -> AnyPublisher<Success, Error>
}


protocol BlockActionsServiceListProtocol {
    associatedtype Delete: BlockActionsServiceListProtocolDelete
    associatedtype SetFields: BlockActionsServiceListProtocolSetFields
    associatedtype SetTextStyle: BlockActionsServiceListProtocolSetTextStyle
    associatedtype Duplicate // : BlockActionsServiceListProtocolDuplicate /// Add conformance later.
    associatedtype SetBackgroundColor: BlockActionsServiceListProtocolSetBackgroundColor
    associatedtype SetAlign: BlockActionsServiceListProtocolSetAlign
    associatedtype SetDivStyle: BlockActionsServiceListProtocolSetDivStyle
    associatedtype SetPageIsArchived: BlockActionsServiceListProtocolSetPageIsArchived
    associatedtype DeletePage: BlockActionsServiceListProtocolDeletePage
    
    var delete: Delete {get}
    var setFields: SetFields {get}
    var setTextStyle: SetTextStyle {get}
    var duplicate: Duplicate {get}
    var setBackgroundColor: SetBackgroundColor {get}
    var setAlign: SetAlign {get}
    var setDivStyle: SetDivStyle {get}
    var setPageIsArchived: SetPageIsArchived {get}
    var deletePage: DeletePage {get}


    /// Set block  color
    /// - Parameters:
    ///   - contextID: page id
    ///   - blockIds: id block
    ///   - color: block  color
    func setBlockColor(contextID: BlockId, blockIds: [BlockId], color: String) -> AnyPublisher<ServiceSuccess, Error>
}
