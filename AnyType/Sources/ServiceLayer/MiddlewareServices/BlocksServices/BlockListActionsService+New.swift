//
//  BlockListActionsService+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

fileprivate typealias Namespace = ServiceLayerModule

protocol NewModel_BlockListActionsServiceProtocolSetFields {
    associatedtype Success
    func action(contextID: String, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) -> AnyPublisher<Success, Error>
}
protocol NewModel_BlockListActionsServiceProtocolSetTextStyle {
    associatedtype Success
    func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error>
}
// TODO: Later enable it and remove old services that works with Duplicates.
//protocol NewModel_BlockListActionsServiceProtocolDuplicate {
//    associatedtype Success
//    func action() -> AnyPublisher<Success, Error>
//}
protocol NewModel_BlockListActionsServiceProtocolSetBackgroundColor {
    associatedtype Success
    func action(contextID: String, blockIds: [String], color: String) -> AnyPublisher<Success, Error>
}
protocol NewModel_BlockListActionsServiceProtocolSetAlign {
    associatedtype Success
    func action(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> AnyPublisher<Success, Error>
}
protocol NewModel_BlockListActionsServiceProtocolSetDivStyle {
    associatedtype Success
    func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<Success, Error>
}
protocol NewModel_BlockListActionsServiceProtocolSetPageIsArchived {
    associatedtype Success
    func action(contextID: String, blockIds: [String], isArchived: Bool) -> AnyPublisher<Success, Error>
}
protocol NewModel_BlockListActionsServiceProtocolDeletePage {
    associatedtype Success
    func action(contextID: String, blockIds: [String], isArchived: Bool) -> AnyPublisher<Success, Error>
}


protocol NewModel_BlockListActionsServiceProtocol {
    associatedtype SetFields
    associatedtype SetTextStyle
    associatedtype Duplicate
    associatedtype SetBackgroundColor
    associatedtype SetAlign
    associatedtype SetDivStyle
    associatedtype SetPageIsArchived
    associatedtype DeletePage
    
    var setFields: SetFields {get}
    var setTextStyle: SetTextStyle {get}
    var duplicate: Duplicate {get}
    var setBackgroundColor: SetBackgroundColor {get}
    var setAlign: SetAlign {get}
    var setDivStyle: SetDivStyle {get}
    var setPageIsArchived: SetPageIsArchived {get}
    var deletePage: DeletePage {get}
}

extension Namespace {
    class BlockListActionsService: NewModel_BlockListActionsServiceProtocol {
        var setFields: SetFields = .init()
        var setTextStyle: SetTextStyle = .init()
        var duplicate: Duplicate = .init()
        var setBackgroundColor: SetBackgroundColor = .init()
        var setAlign: SetAlign = .init()
        var setDivStyle: SetDivStyle = .init()
        var setPageIsArchived: SetPageIsArchived = .init()
        var deletePage: DeletePage = .init()
    }
}

extension Namespace.BlockListActionsService {
    typealias Success = ServiceLayerModule.Success
    
    struct SetFields {
        func action(contextID: String, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Fields.Service.invoke(contextID: contextID, blockFields: blockFields).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct SetTextStyle {
        func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Text.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct Duplicate {
        func action(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Duplicate.Service.invoke(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct SetBackgroundColor {
        func action(contextID: String, blockIds: [String], color: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.BackgroundColor.Service.invoke(contextID: contextID, blockIds: blockIds, color: color).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct SetAlign {
        func action(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Align.Service.invoke(contextID: contextID, blockIds: blockIds, align: align).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct SetDivStyle {
        func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Div.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct SetPageIsArchived {
        func action(contextID: String, blockIds: [String], isArchived: Bool) -> AnyPublisher<Success, Error> {
            // TODO: Implement it correctly.
            .empty()
//            Anytype_Rpc.BlockList.Set.Page.IsArchived.Service.invoke(contextID: contextID, blockIds: blockIds, isArchived: isArchived).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    struct DeletePage {
        func action(blockIds: [String]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Delete.Page.Service.invoke(blockIds: blockIds).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}
