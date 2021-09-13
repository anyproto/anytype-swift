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
}


protocol ObjectActionsServiceProtocol {
    func convertChildrenToPages(
        contextID: BlockId,
        blocksIds: [BlockId],
        objectType: String
    ) -> AnyPublisher<[BlockId], Error>
    
    /// NOTE: You have to convert value to List<Anytype_Rpc.Block.Set.Details.Detail>.
    func setDetails(
        contextID: BlockId,
        details: [DetailsKind: DetailsEntry<AnyHashable>]
    ) -> AnyPublisher<ResponseEvent, Error>
    
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
    func createPage(
        contextID: BlockId,
        targetID: BlockId,
        details: [DetailsKind: DetailsEntry<AnyHashable>],
        position: BlockPosition,
        templateID: String
    ) -> AnyPublisher<CreatePageResponse, Error>
    
    @discardableResult
    func move(
        dashboadId: BlockId,
        blockId: BlockId,
        dropPositionblockId: BlockId,
        position: Anytype_Model_Block.Position
    ) -> AnyPublisher<Void, Error>
}
