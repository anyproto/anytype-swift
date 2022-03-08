import BlocksModels

final class InfoContainerMock: InfoContainerProtocol {
    var getStub = false
    var getReturnInfo: BlockInformation?
    var getNumberOfCalls = 0
    var getBlockId: BlockId?
    func get(id: BlockId) -> BlockInformation? {
        if getStub {
            getNumberOfCalls += 1
            getBlockId = id
            return getReturnInfo
        } else {
            assertionFailure()
            return nil
        }
    }
    
    var childrenStub = false
    var childrenNumberOfCalls = 0
    var childrenId: BlockId?
    var childrenReturnInfo = [BlockInformation]()
    func children(of id: BlockId) -> [BlockInformation] {
        if childrenStub {
            childrenNumberOfCalls += 1
            childrenId = id
            return childrenReturnInfo
        } else {
            assertionFailure()
            return []
        }
    }
    
    func add(_ info: BlockInformation) {
        assertionFailure()
    }
    
    func remove(id: BlockId) {
        assertionFailure()
    }
    
    func setChildren(ids: [BlockId], parentId: BlockId) {
        assertionFailure()
    }
    
    func update(blockId: BlockId, update: @escaping (BlockInformation) -> (BlockInformation?)) {
        assertionFailure()
    }
    
    func updateDataview(blockId: BlockId, update: @escaping (BlockDataview) -> (BlockDataview)) {
        assertionFailure()
    }
}
