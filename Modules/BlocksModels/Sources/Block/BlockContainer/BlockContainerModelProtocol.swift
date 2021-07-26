/// We need to distinct Container and BlockContainer.
/// One of them contains UserSession.
/// Another contains BlockContainer and DetailsContainer.
public protocol BlockContainerModelProtocol: AnyObject {
    var userSession: UserSession { get set }
    var rootId: BlockId? {get set}

    func children(of id: BlockId) -> [BlockId]

    /// Obtain block model
    func model(id: BlockId) -> BlockModelProtocol?

    // Remove block model by id
    func remove(_ id: BlockId)

    /// Add block model to container
    func add(_ block: BlockModelProtocol)

    /// Add block model before other block model
    func add(child: BlockId, beforeChild: BlockId)

    /// Add block model after other block model
    func add(child: BlockId, afterChild: BlockId)

    /// Replace block model after other block model
    func replace(childrenIds: [BlockId], parentId: BlockId, shouldSkipGuardAgainstMissingIds: Bool)
}
