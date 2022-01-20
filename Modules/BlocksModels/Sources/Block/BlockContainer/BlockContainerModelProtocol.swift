/// We need to distinct Container and BlockContainer.
/// Another contains BlockContainer and DetailsContainer.
public protocol BlockContainerModelProtocol: AnyObject {
    var rootId: BlockId? {get set}

    func children(of id: BlockId) -> [BlockId]

    func model(id: BlockId) -> BlockModelProtocol?
    func remove(_ id: BlockId)
    func add(_ block: BlockModelProtocol)
    func add(child: BlockId, beforeChild: BlockId)
    func add(child: BlockId, afterChild: BlockId)
    func replace(childrenIds: [BlockId], parentId: BlockId, shouldSkipGuardAgainstMissingIds: Bool)
    
    func update(blockId: BlockId, update: @escaping (BlockModelProtocol) -> ())
    func updateDataview(blockId: BlockId, update: @escaping (BlockDataview) -> (BlockDataview))
}
