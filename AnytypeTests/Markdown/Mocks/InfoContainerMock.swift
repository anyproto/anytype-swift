import Services
import Combine
import XCTest

final class InfoContainerMock: InfoContainerProtocol, @unchecked Sendable {
    func recursiveChildren(of id: String) -> [BlockInformation] {
        []
    }
    
    func publisherFor(id: String) -> AnyPublisher<BlockInformation?, Never> {
        assertionFailure()
        return PassthroughSubject().eraseToAnyPublisher()
    }

    var getReturnInfo = [String: BlockInformation]()
    func get(id: String) -> BlockInformation? {
        guard let info = getReturnInfo[id] else {
            XCTFail()
            return nil
        }
        return info
    }
    
    private var childrenReturnInfo = [String: [BlockInformation]]()
    func stubChildForParent(parentId: String, child: BlockInformation?) {
        var data: [BlockInformation] = childrenReturnInfo[parentId] ?? []
        child.flatMap { data.append($0) }
        childrenReturnInfo[parentId] = data
    }
    
    func children(of id: String) -> [BlockInformation] {
        guard let children = childrenReturnInfo[id] else {
            XCTFail()
            return []
        }
        
        return children
    }
    
    func add(_ info: BlockInformation) {
        assertionFailure()
    }
    
    func remove(id: String) {
        assertionFailure()
    }
    
    func setChildren(ids: [String], parentId: String) {
        assertionFailure()
    }
    
    func update(blockId: String, update: (BlockInformation) -> (BlockInformation?)) {
        assertionFailure()
    }
    
    func updateDataview(blockId: String, update: (BlockDataview) -> (BlockDataview)) {
        assertionFailure()
    }
    
    func publishAllValues() {}
    
    func publishValue(for key: String) {}
}
