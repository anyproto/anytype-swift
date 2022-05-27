public protocol InfoContainerProtocol: AnyObject {
    func children(of id: BlockId) -> [BlockInformation]
    func recursiveChildren(of id: BlockId) -> [BlockInformation]

    func `get`(id: BlockId) -> BlockInformation?
    func add(_ info: BlockInformation)
    func remove(id: BlockId)
    
    func setChildren(ids: [BlockId], parentId: BlockId)
    
    func update(blockId: BlockId, update: @escaping (BlockInformation) -> (BlockInformation?))
    func updateDataview(blockId: BlockId, update: @escaping (BlockDataview) -> (BlockDataview))
}
