
import ProtobufMessages

/// Success response on split block
struct SplitSuccess {
    let blockId: String
    let responseEvent: ResponseEvent

    init(_ response: Anytype_Rpc.Block.Split.Response) {
        self.blockId = response.blockID
        self.responseEvent = ResponseEvent(response.event)
    }
}

