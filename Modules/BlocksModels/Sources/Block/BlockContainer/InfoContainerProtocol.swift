/// We need to distinct Container and InfoContainer.
/// Another contains InfoContainer and DetailsContainer.
public protocol InfoContainerProtocol: AnyObject {
    func children(of info: BlockId) -> [BlockInformation]

    func `get`(id: BlockId) -> BlockInformation?
    func add(_ info: BlockInformation)
    func remove(id: BlockId)
    
    func setChildren(ids: [BlockId], parentId: BlockId)
    
    func update(blockId: BlockId, update: @escaping (BlockInformation) -> (BlockInformation?))
    func updateDataview(blockId: BlockId, update: @escaping (BlockDataview) -> (BlockDataview))
}
