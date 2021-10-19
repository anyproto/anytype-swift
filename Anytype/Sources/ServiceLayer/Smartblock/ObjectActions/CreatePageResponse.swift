import ProtobufMessages
import BlocksModels

struct CreatePageResponse {
    let newBlockId: BlockId
    let messages: [Anytype_Event.Message]

    init(_ response: ProtobufMessages.Anytype_Rpc.Block.CreatePage.Response) {
        self.newBlockId = response.targetID
        self.messages = response.event.messages
    }
    
    init(_ response: ProtobufMessages.Anytype_Rpc.Page.Create.Response) {
        self.newBlockId = response.pageID
        self.messages = response.event.messages
    }
}
