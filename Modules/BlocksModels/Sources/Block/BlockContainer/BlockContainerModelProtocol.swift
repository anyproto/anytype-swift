/// We need to distinct Container and BlockContainer.
/// Another contains BlockContainer and DetailsContainer.
public protocol BlockContainerModelProtocol: AnyObject {
    func children(of id: BlockId) -> [BlockInformation]

    func model(id: BlockId) -> BlockInformation?
    func remove(_ id: BlockId)
    func add(_ block: BlockInformation)
    func set(childrenIds: [BlockId], parentId: BlockId)
    
    func update(blockId: BlockId, update: @escaping (BlockInformation) -> (BlockInformation?))
    func updateDataview(blockId: BlockId, update: @escaping (BlockDataview) -> (BlockDataview))
}
