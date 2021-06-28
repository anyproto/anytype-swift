/// We need to distinct Container and BlockContainer.
/// One of them contains UserSession.
/// Another contains BlockContainer and DetailsContainer.
public protocol BlockContainerModelProtocol: AnyObject {
    typealias UserSession = BlockUserSessionModelProtocol
    var userSession: UserSession {get}
    
    var rootId: BlockId? {get set}
    
    // MARK: - Operations / List
    func list() -> AnyIterator<BlockId>
    func children(of id: BlockId) -> [BlockId]
    // MARK: - Operations / Choose
    func choose(by id: BlockId) -> BlockActiveRecordProtocol?
    // MARK: - Operations / Get
    func get(by id: BlockId) -> BlockModelProtocol?
    // MARK: - Operations / Remove
    func remove(_ id: BlockId)
    // MARK: - Operations / Add
    func add(_ block: BlockModelProtocol)
    // MARK: - Children / Append
    func append(childId: BlockId, parentId: BlockId)
    // MARK: - Children / Add Before
    func add(child: BlockId, beforeChild: BlockId)
    // MARK: - Children / Add
    func add(child: BlockId, afterChild: BlockId)
    // MARK: - Children / Replace
    func replace(childrenIds: [BlockId], parentId: BlockId, shouldSkipGuardAgainstMissingIds: Bool)
}
