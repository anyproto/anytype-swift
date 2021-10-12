
import ProtobufMessages

/// Success response on split block
struct SplitSuccess {
    let blockId: String
    let responseEvent: MiddlewareResponse

    init(_ response: Anytype_Rpc.Block.Split.Response) {
        self.blockId = response.blockID
        self.responseEvent = MiddlewareResponse(response.event)
    }
}

