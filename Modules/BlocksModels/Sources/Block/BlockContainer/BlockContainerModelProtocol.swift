/// We need to distinct Container and BlockContainer.
/// One of them contains UserSession.
/// Another contains BlockContainer and DetailsContainer.
public protocol BlockContainerModelProtocol: AnyObject {
    var userSession: UserSession { get set }
    
    var rootId: BlockId? {get set}
    
    func children(of id: BlockId) -> [BlockId]
    // MARK: - Operations / Choose
    func record(id: BlockId) -> BlockActiveRecordProtocol?
    // MARK: - Operations / Get
    func model(id: BlockId) -> BlockModelProtocol?
    // MARK: - Operations / Remove
    func remove(_ id: BlockId)
    // MARK: - Operations / Add
    func add(_ block: BlockModelProtocol)
    // MARK: - Children / Add Before
    func add(child: BlockId, beforeChild: BlockId)
    // MARK: - Children / Add
    func add(child: BlockId, afterChild: BlockId)
    // MARK: - Children / Replace
    func replace(childrenIds: [BlockId], parentId: BlockId, shouldSkipGuardAgainstMissingIds: Bool)
}
