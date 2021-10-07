import Combine
import BlocksModels
import ProtobufMessages

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


protocol ObjectActionsServiceProtocol {
    func convertChildrenToPages(
        contextID: BlockId,
        blocksIds: [BlockId],
        objectType: String
    ) -> AnyPublisher<[BlockId], Error>
    
    func syncSetDetails(contextID: BlockId, details: RawDetailsData) -> ResponseEvent?
    /// NOTE: You have to convert value to List<Anytype_Rpc.Block.Set.Details.Detail>.
    func asyncSetDetails(
        contextID: BlockId, details: RawDetailsData
    ) -> AnyPublisher<ResponseEvent, Error>
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
    func createPage(
        contextID: BlockId,
        targetID: BlockId,
        details: RawDetailsData,
        position: BlockPosition,
        templateID: String
    ) -> CreatePageResponse?
    
    @discardableResult
    func move(
        dashboadId: BlockId,
        blockId: BlockId,
        dropPositionblockId: BlockId,
        position: Anytype_Model_Block.Position
    ) -> AnyPublisher<Void, Error>
}
