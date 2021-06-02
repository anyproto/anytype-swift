import Foundation
import os

public protocol BlockBuilderProtocol {
    func build(list: [BlockModelProtocol]) -> BlockContainerModelProtocol
    func buildTree(container: BlockContainerModelProtocol, rootId: String?)
    func emptyContainer() -> BlockContainerModelProtocol
    func createBlockModel(with information: BlockInformation) -> BlockModelProtocol
    var informationBuilder: BlockInformationBuilderProtocol {get}
}

public class TopLevelBlockBuilder: BlockBuilderProtocol {
    public static let shared: BlockBuilderProtocol = TopLevelBlockBuilder()
    
    public func build(list: [BlockModelProtocol]) -> BlockContainerModelProtocol {
        let container = BlockContainer()
        list.forEach(container.add(_:))
        return container
    }
    
    public func emptyContainer() -> BlockContainerModelProtocol {
        build(list: [])
    }
    
    private func buildTreeRecursively(container: BlockContainerModelProtocol, id: BlockId) {
        if let entry = container.choose(by: id) {
            let parentId = id
            entry.childrenIds().forEach { (value) in
                var blockModel = entry.findChild(by: value)?.blockModel
                blockModel?.parent = parentId
                self.buildTreeRecursively(container: container, id: value)
            }
        }
    }
    
    public func buildTree(container: BlockContainerModelProtocol, rootId: String?) {
        if let rootId = rootId {
            self.buildTreeRecursively(container: container, id: rootId)
        }
        else {
            assertionFailure("Can't build tree. RootId is nil")
        }
    }
    
    public func createBlockModel(with information: BlockInformation) -> BlockModelProtocol {
        BlockModel(information: information)
    }
    
    public let informationBuilder: BlockInformationBuilderProtocol = BlockInformationBuilder()
}
