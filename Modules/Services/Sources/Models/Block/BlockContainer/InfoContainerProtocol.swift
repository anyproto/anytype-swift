import Combine

public protocol InfoContainerProtocol: AnyObject {
    
    func publisherFor(id: BlockId) -> AnyPublisher<BlockInformation?, Never>
    func publishAllValues()
    func publishValue(for key: BlockId)
    
    func children(of id: String) -> [BlockInformation]
    func recursiveChildren(of id: String) -> [BlockInformation]

    func `get`(id: String) -> BlockInformation?
    func add(_ info: BlockInformation)
    func remove(id: String)
    
    func setChildren(ids: [String], parentId: String)
    
    func update(blockId: String, update: (BlockInformation) -> (BlockInformation?))
}
