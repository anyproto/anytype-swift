import Foundation
import os

public protocol BlockBuilderProtocol {
    func build(list: [BlockModelProtocol]) -> BlockContainerModelProtocol
    func buildTree(container: BlockContainerModelProtocol, rootId: String?)
    func emptyContainer() -> BlockContainerModelProtocol
    func createBlockModel(with information: BlockInformation.InformationModel) -> BlockModelProtocol
    var informationBuilder: BlockInformationBuilderProtocol {get}
}

extension Block {
    class Builder: BlockBuilderProtocol {
        typealias CurrentContainer = Container
        typealias InformationBuilder = BlockInformation.Builder
        
        func build(list: [BlockModelProtocol]) -> BlockContainerModelProtocol {
            let container: CurrentContainer = .init()
            list.forEach(container.add(_:))
            return container
        }
        
        func emptyContainer() -> BlockContainerModelProtocol {
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
        
        func buildTree(container: BlockContainerModelProtocol, rootId: String?) {
            if let rootId = rootId {
                self.buildTreeRecursively(container: container, id: rootId)
            }
            else {
                assertionFailure("Can't build tree. RootId is nil")
            }
        }
        
        func createBlockModel(with information: BlockInformation.InformationModel) -> BlockModelProtocol {
            BlockModel(information: information)
        }
        
        // MARK: Information
        var informationBuilder: BlockInformationBuilderProtocol = InformationBuilder.init()
    }
}
