import BlocksModels
import XCTest

final class InfoContainerMock: InfoContainerProtocol {
    func recursiveChildren(of id: BlockId) -> [BlockInformation] {
        []
    }

    var getReturnInfo = [BlockId: BlockInformation]()
    func get(id: BlockId) -> BlockInformation? {
        guard let info = getReturnInfo[id] else {
            XCTFail()
            return nil
        }
        return info
    }
    
    private var childrenReturnInfo = [BlockId: [BlockInformation]]()
    func stubChildForParent(parentId: BlockId, child: BlockInformation?) {
        var data: [BlockInformation] = childrenReturnInfo[parentId] ?? []
        child.flatMap { data.append($0) }
        childrenReturnInfo[parentId] = data
    }
    
    func children(of id: BlockId) -> [BlockInformation] {
        guard let children = childrenReturnInfo[id] else {
            XCTFail()
            return []
        }
        
        return children
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
