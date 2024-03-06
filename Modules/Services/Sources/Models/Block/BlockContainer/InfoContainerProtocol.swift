import Combine

public protocol InfoContainerProtocol: AnyObject {
    
    func publisherFor(id: String) -> AnyPublisher<BlockInformation?, Never>
    func publishAllValues()
    func publishValue(for key: String)
    
    func children(of id: String) -> [BlockInformation]
    func recursiveChildren(of id: String) -> [BlockInformation]

    func `get`(id: String) -> BlockInformation?
    func add(_ info: BlockInformation)
    func remove(id: String)
    
    func setChildren(ids: [String], parentId: String)
    
    func update(blockId: String, update: (BlockInformation) -> (BlockInformation?))
}
