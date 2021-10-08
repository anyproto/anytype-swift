import Foundation
import Combine
import BlocksModels
import ProtobufMessages

/// Concrete service that adopts OtherBlock actions service.
/// NOTE: Use it as default service IF you want to use default functionality.
// MARK: - OtherBlockActionsService

class BlockActionsServiceOther: BlockActionsServiceOtherProtocol {
    var setDividerStyle = SetDividerStyle()

    /// Structure that adopts `CreatePage` action protocol
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    struct SetDividerStyle: BlockActionsServiceOtherProtocolSetDividerStyle {
        func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<ResponseEvent, Error> {
            Anytype_Rpc.BlockList.Set.Div.Style.Service
                .invoke(contextID: contextID, blockIds: blockIds, style: style.asMiddleware)
                .map { ResponseEvent($0.event) }
                .eraseToAnyPublisher()
        }
    }
}

